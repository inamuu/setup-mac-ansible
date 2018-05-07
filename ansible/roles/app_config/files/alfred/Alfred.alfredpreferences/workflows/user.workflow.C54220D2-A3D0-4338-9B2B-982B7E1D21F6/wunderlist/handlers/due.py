# encoding: utf-8

from datetime import date, datetime, timedelta

from peewee import JOIN, OperationalError
from workflow.background import is_running

from wunderlist import icons
from wunderlist.models.list import List
from wunderlist.models.preferences import Preferences
from wunderlist.models.task import Task
from wunderlist.sync import background_sync, background_sync_if_necessary, sync
from wunderlist.util import relaunch_alfred, workflow

_hashtag_prompt_pattern = r'#\S*$'

_due_orders = (
    {
        'due_order': ['order', 'due_date', 'list.order'],
        'title': 'Most overdue within each list',
        'subtitle': 'Sort tasks by increasing due date within lists (Wunderlist default)'
    },
    {
        'due_order': ['order', '-due_date', 'list.order'],
        'title': 'Most recently due within each list',
        'subtitle': 'Sort tasks by decreasing due date within lists'
    },
    {
        'due_order': ['order', 'due_date'],
        'title': 'Most overdue at the top',
        'subtitle': 'All tasks sorted by increasing due date'
    },
    {
        'due_order': ['order', '-due_date'],
        'title': 'Most recently due at the top',
        'subtitle': 'All tasks sorted by decreasing due date'
    }
)


def filter(args):
    wf = workflow()
    prefs = Preferences.current_prefs()
    command = args[1] if len(args) > 1 else None

    # Show sort options
    if command == 'sort':
        for i, order_info in enumerate(_due_orders):
            wf.add_item(order_info['title'], order_info['subtitle'], arg='-due sort %d' % (i + 1), valid=True, icon=icons.RADIO_SELECTED if order_info['due_order'] == prefs.due_order else icons.RADIO)

        wf.add_item('Highlight skipped recurring tasks', 'Hoists recurring tasks that have been missed multiple times over to the top', arg='-due sort toggle-skipped', valid=True, icon=icons.CHECKBOX_SELECTED if prefs.hoist_skipped_tasks else icons.CHECKBOX)

        wf.add_item('Back', autocomplete='-due ', icon=icons.BACK)

        return

    # Force a sync if not done recently or wait on the current sync
    if not prefs.last_sync or \
       datetime.now() - prefs.last_sync > timedelta(seconds=30) or \
       is_running('sync'):
        sync()

    conditions = True

    # Build task title query based on the args
    for arg in args[1:]:
        if len(arg) > 1:
            conditions = conditions & (Task.title.contains(arg) | List.title.contains(arg))

    if conditions is None:
        conditions = True

    tasks = Task.select().join(List).where(
        Task.completed_at.is_null() &
        (Task.due_date < date.today() + timedelta(days=1)) &
        Task.list.is_null(False) &
        conditions
    )

    # Sort the tasks according to user preference
    for key in prefs.due_order:
        order = 'asc'
        field = None
        if key[0] == '-':
            order = 'desc'
            key = key[1:]

        if key == 'due_date':
            field = Task.due_date
        elif key == 'list.order':
            field = List.order
        elif key == 'order':
            field = Task.order

        if field:
            if order == 'asc':
                tasks = tasks.order_by(field.asc())
            else:
                tasks = tasks.order_by(field.desc())

    try:
        if prefs.hoist_skipped_tasks:
            tasks = sorted(tasks, key=lambda t: -t.overdue_times)

        for t in tasks:
            wf.add_item(u'%s – %s' % (t.list_title, t.title), t.subtitle(), autocomplete='-task %s ' % t.id, icon=icons.TASK_COMPLETED if t.completed else icons.TASK)
    except OperationalError:
        background_sync()

    wf.add_item(u'Sort order', 'Change the display order of due tasks', autocomplete='-due sort', icon=icons.SORT)

    wf.add_item('Main menu', autocomplete='', icon=icons.BACK)

    # Make sure tasks stay up-to-date
    background_sync_if_necessary(seconds=2)

def commit(args, modifier=None):
    action = args[1]
    prefs = Preferences.current_prefs()
    relaunch_command = None

    if action == 'sort' and len(args) > 2:
        command = args[2]

        if command == 'toggle-skipped':
            prefs.hoist_skipped_tasks = not prefs.hoist_skipped_tasks
            relaunch_command = 'wl-due sort'
        else:
            try:
                index = int(command)
                order_info = _due_orders[index - 1]
                prefs.due_order = order_info['due_order']
                relaunch_command = 'wl-due '
            except IndexError:
                pass
            except ValueError:
                pass

    if relaunch_command:
        relaunch_alfred(relaunch_command)
