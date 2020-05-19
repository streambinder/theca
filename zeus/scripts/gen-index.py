#!/usr/bin/env python3

from _common import series

print(
    '| Name | Summary | Version |\n',
    '| ---- | ------- | :-----: |'
)
for eopkg in series():
    print('| `{}` | {} | `{}` |'.format(
        eopkg.name, eopkg.summary, eopkg.version))
