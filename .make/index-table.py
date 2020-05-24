#!/usr/bin/env python3

from common import series

print(
    '# Index\n\n',
    '| Name | Summary | Version |\n',
    '| ---- | ------- | :-----: |'
)
for eopkg in series():
    print('| `{}` | {} | `{}` |'.format(
        eopkg.name, eopkg.summary, eopkg.version))
