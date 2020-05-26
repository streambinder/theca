#!/usr/bin/env python3

from common import series

print(
    '# Index\n\n',
    '| Name | Version |\n',
    '| ---- | :-----: |'
)
for eopkg in series():
    print('| `{}` <br> {} | `{}` |'.format(
        eopkg.name, eopkg.summary, eopkg.version))
