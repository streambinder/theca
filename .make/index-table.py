#!/usr/bin/env python3

from common import series

print(
    '# Index\n\n',
    '| Name | Version |\n',
    '| :--- | ------: |'
)
for eopkg in series():
    print('| `{}` <br> {} | `{}` |'.format(
        eopkg.name,
        eopkg.summary if type(eopkg.summary) != list else eopkg.summary[0],
        eopkg.version
    ))
