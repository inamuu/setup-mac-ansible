# encoding: utf-8

from datetime import date
import logging
import time

from peewee import (BooleanField, CharField, DateField, ForeignKeyField,
                    IntegerField, PeeweeException, PrimaryKeyField, TextField,
                    JOIN)

from wunderlist.models.fields import DateTimeUTCField
from wunderlist.models.base import BaseModel
from wunderlist.models.list import List
from wunderlist.models.user import User
from wunderlist.util import short_relative_formatted_date, NullHandler

log = logging.getLogger(__name__)
log.addHandler(NullHandler())

_days_by_recurrence_type = {
    'day': 1,
    'week': 7,
    'month': 30.43,
    'year': 365
}

_star = u'★'
_overdue_1x = u'⚠️'
_overdue_2x = u'❗️'
_recurrence = u'↻'
_reminder = u'⏰'

class Task(BaseModel):
    id = PrimaryKeyField()
    list = ForeignKeyField(List, null=True, related_name='tasks')
    task = ForeignKeyField('self', null=True, related_name='subtasks')
    title = TextField(index=True)
    completed_at = DateTimeUTCField(null=True)
    completed_by = ForeignKeyField(User, related_name='completed_tasks', null=True)
    starred = BooleanField(index=True, null=True)
    due_date = DateField(index=True, null=True)
    recurrence_type = CharField(null=True)
    recurrence_count = IntegerField(null=True)
    assignee = ForeignKeyField(User, related_name='assigned_tasks', null=True)
    order = IntegerField(index=True, null=True)
    revision = IntegerField()
    created_at = DateTimeUTCField()
    created_by = ForeignKeyField(User, related_name='created_tasks', null=True)

    @classmethod
    def sync_tasks_in_list(cls, list):
        from wunderlist.api import tasks
        from concurrent import futures
        start = time.time()
        instances = []
        tasks_data = []
        position_by_task_id = {}

        with futures.ThreadPoolExecutor(max_workers=4) as executor:
            positions_job = executor.submit(tasks.task_positions, list.id)
            jobs = (
                executor.submit(tasks.tasks, list.id, completed=False),
                executor.submit(tasks.tasks, list.id, completed=True),
                executor.submit(tasks.tasks, list.id, subtasks=True)
            )

            for job in futures.as_completed(jobs):
                tasks_data += job.result()

            position_by_task_id = dict((id, index) for (id, index) in enumerate(positions_job.result()))

        log.info('Retrieved all %d tasks for %s in %s', len(tasks_data), list, time.time() - start)
        start = time.time()

        def task_order(task):
            task['order'] = position_by_task_id.get(task['id'])
            return task['order'] or 1e99

        tasks_data.sort(key=task_order)

        try:
            # Include all tasks thought to be in the list, plus any additional
            # tasks referenced in the data (task may have been moved to a different list)
            ParentTask = cls.alias()
            task_ids = [task['id'] for task in tasks_data]
            instances = cls.select(cls.id, cls.title, cls.revision)\
                .join(ParentTask, JOIN.LEFT_OUTER)\
                .where(
                    (ParentTask.list == list.id) |
                    (cls.list == list.id) |
                    (cls.id.in_(task_ids)) |
                    (cls.task.in_(task_ids))
                )
        except PeeweeException:
            pass

        log.info('Loaded all %d tasks for %s from the database in %s', len(instances), list, time.time() - start)
        start = time.time()

        cls._perform_updates(instances, tasks_data)

        log.info('Completed updates to tasks in %s in %s', list, time.time() - start)

        return None

    @classmethod
    def due_today(cls):
        return (
            cls.select(cls, List)
            .join(List)
            .where(cls.completed_at >> None)
            .where(cls.due_date <= date.today())
            .order_by(List.order.asc(), cls.due_date.asc())
        )

    @classmethod
    def search(cls, query):
        return (
            cls.select(cls, List)
            .join(List)
            .where(cls.completed_at >> None)
            .where(cls.title.contains(query))
            .order_by(List.order.asc(), cls.due_date.asc())
        )

    @property
    def reminder_date_local(self):
        # For related property Task.reminders
        import wunderlist.models.reminder

        for reminder in self.reminders:
            return reminder.date_local
        return None

    @property
    def completed(self):
        return bool(self.completed_at)

    @property
    def overdue_times(self):
        if self.recurrence_type is None or self.completed:
            return 0

        recurrence_days = _days_by_recurrence_type[self.recurrence_type] * self.recurrence_count
        overdue_time = date.today() - self.due_date
        return int(overdue_time.days / recurrence_days)

    @property
    def list_title(self):
        if self.list:
            return self.list.title
        return None

    def subtitle(self):
        from wunderlist.util import format_time

        subtitle = []

        if self.starred:
            subtitle.append(_star)

        # Task is completed
        if self.completed:
            subtitle.append('Completed %s' % short_relative_formatted_date(self.completed_at))
        # Task is not yet completed
        elif self.due_date:
            subtitle.append('Due %s' % short_relative_formatted_date(self.due_date))

        if self.recurrence_type:
            if self.recurrence_count > 1:
                subtitle.append('%s Every %d %ss' % (_recurrence, self.recurrence_count, self.recurrence_type))
            # Cannot simply add -ly suffix
            elif self.recurrence_type == 'day':
                subtitle.append('%s Daily' % (_recurrence))
            else:
                subtitle.append('%s %sly' % (_recurrence, self.recurrence_type.title()))

        if not self.completed:
            overdue_times = self.overdue_times
            if overdue_times > 1:
                subtitle.insert(0, u'%s %dX OVERDUE!' % (_overdue_2x, overdue_times))
            elif overdue_times == 1:
                subtitle.insert(0, u'%s OVERDUE!' % (_overdue_1x))

            reminder_date = self.reminder_date_local
            if reminder_date:
                reminder_date_phrase = None

                if reminder_date.date() == self.due_date:
                    reminder_date_phrase = 'On due date'
                else:
                    reminder_date_phrase = short_relative_formatted_date(reminder_date)

                subtitle.append('%s %s at %s' % (
                    _reminder,
                    reminder_date_phrase,
                    format_time(reminder_date, 'short')))

        subtitle.append(self.title)

        return '   '.join(subtitle)

    def __str__(self):
        title = self.title if len(self.title) <= 20 else self.title[:20].rstrip() + u'…'
        return u'<%s %d %s>' % (type(self).__name__, self.id, title)

    class Meta(object):
        order_by = ('order', 'id')
