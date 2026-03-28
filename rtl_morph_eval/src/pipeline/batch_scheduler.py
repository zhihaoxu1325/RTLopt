from __future__ import annotations

from itertools import islice
from typing import Iterable


def batched(items: Iterable, batch_size: int):
    it = iter(items)
    while True:
        chunk = list(islice(it, batch_size))
        if not chunk:
            break
        yield chunk
