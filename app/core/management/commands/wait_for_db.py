"""
Django command to wait for database to be available.
"""

import time


from typing import Any
from django.core.management.base import BaseCommand
from django.db.utils import OperationalError

from psycopg import OperationalError as PsycopgOpError

class Command(BaseCommand):
    """Django command to wait for database."""

    def handle(self, *args: Any, **options: Any) -> str | None:
        """Entrypoint for command."""
        self.stdout.write('Waiting for database...')
        db_up = False
        while not db_up:
            try:
                self.check(databases=['default'])
                db_up = True
            except (PsycopgOpError, OperationalError):
                self.stdout.write('Database available, waiting 1 second')
                time.sleep(1)

        self.stdout.write(self.style.SUCCESS('Database is available'))
