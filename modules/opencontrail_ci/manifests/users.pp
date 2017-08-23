class opencontrail_ci::users {
  # ensure that the ubuntu user is locked.
  # XXX: we really should just delete the user, but that wreaks havoc with assumptions made
  # by the bootstrap process.
  accounts::user { 'ubuntu':
    locked => true,
  }

  # lint:ignore:140chars
  accounts::user { 'kklimonda':
    ensure        => present,
    comment       => 'Krzysztof Klimonda',
    groups        => [ 'sudo' ],
    uid           => '1001',
    gid           => '1001',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8xYbz7ohnFJuo8pvaRmzzRazLAPzGTcwcq848iKx6W9OZWjHMKJ40TiMM4RyeWvjGP68aEkLA6Pgdrxlf1e2rmiIH5il+znLEHslnpA3FjWbRMx5HiXn4ZKmVvFU8uGmXPeevMbHM+YJdxkMjAdf9uV8pA4EmUcsdyxK9oLZFDWsvJEeZXz6Andc+wpYCNh3FNoRO0+lIhuFdzXhf2a9mVqV3TmkgUW4KojH03kEGzudsZ+9ZZuKOe2TevHA58atabSiKQfg7T2q1EmNObpcEacxFiVsmT8DgbkHjN+AftsFulUKPA9kzfSYmfAX238Ib4aSKcvpONPi/RKzh5ee3 kklimonda@noise',
    ]
  }

  accounts::user { 'jluk':
    ensure        => present,
    comment       => 'Jaroslaw Lukow',
    groups        => [ 'sudo' ],
    uid           => '1002',
    gid           => '1002',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvHlOvM6E0vBQHEhBsBsULqtaySmpvi50c4zp8zpWqnl4Br1jc4aABpnmM3EmBAfSlKjbk3LK1N1PHdh7m+ADwpumWX1MnVh1BZqL9Cm5r0pBEfZEpslqWbwsD+ym6RkJ8OdQB7uHjvbQ6xYma4ptEaXaq4UGcWUiLICt4tTEy9P2YZBZfGXv4XWJfBWUr2UhK3MbGOmquk3grB9OmesBZYG88UXcFy15NWEFIXQZsBIEU7jFtAEVpDhVN7aNYH+CvOU7AQ/pgqlRv1+ZTrDehAlp93eONAs9sxxyL2QF7O8v+O2doPiIW2QO3ila852c0qo3udM0DAfWYhbJPYC4PAVuTYdLx18RkLBXlfE8JPFf+UOJ63lQGqTn8vyhUfjpW+3OAY0/xGzZncDvGqbBEQ/N6zQAxAlKOmAb0b5oaUyFLnJ3KrYS3yDAHXl8E98PPDkoIyHQ+pNo3EBLNe91MJ5kMEiL/zU7gc4stNFT6HZQJNObQu200yKBFdjAgYM/BqbUk5YkrQMo3qpTZk1fP2TuLLmJADwEQ7yLZq88J6vqDsQqReQtGn/espwwjTi7uVfoYovdVkmrXw8BpKk9ti5R2+K/eFDCO85MxVpp+2/45noH8+mtDj+FGOx1P+Y0sqVP0ePYbASKngcm0HDVWdg2ZFA7GuE7CtS3EPzgAKw== jaroslaw@jaroslaw-lukow',
    ]
  }

  accounts::user { 'lukasz.lukasiewicz':
    ensure        => present,
    comment       => 'Lukasz Lukasiewicz',
    groups        => [ 'sudo' ],
    uid           => '1003',
    gid           => '1003',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxMPK7PS/rYZ8+kwzuqs25T2S3WcCBV4X8kUwbYx46INV8ocHfE8ZJGLtYeAKkfeZLjpb6z+ksSK/rXlsVlcNHlUm7ikVPXkDtSuzBsn5cYXEtoqXfskWja6JIidQX3qpC/QGLub98siOTVTPEoujRT0TAmkRmRXy2z8mPlz3tWrrLjSQHE3VyczgIv3Zv61VmjIJ6fXyv333R3lh9Lc86pcZrb8p849eJ+VFcX8UKmFgSAgELae8oPbS5f8EHV2mRoKo+F+zxh6TwZLFWSs3yRmuvh5zdFXPOQp52MUzu/hsPfBoiFkV2+V5494jl8Nx7BMZd22ckHmyiefqwGdC7 lukasz.lukasiewicz@HellNote',
    ]
  }

  accounts::user { 'pjrusak':
    ensure        => present,
    comment       => 'Pawel Rusak',
    groups        => [ 'sudo' ],
    uid           => '1004',
    gid           => '1004',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZRWPsDnCCD/krWhk4Zy1SCCR2xS5hGSxW/08TRmWTjenzdrsFEBVKV9gJA5gJVRabebOeRMdBE3bYEHUdU+aCsngkO6Lid/itpUR3u6QKTboxkO7uH+mvVbMIxorl4ufYRk6axL7y3VoGrFwR0Sl9kvtncrjqUcfpNcVrNuP/0EzOKXVp6xhZVAYYLg1/0lCDhq/M2uMG1MHEXk52u6eAZarRqbOE3TU+Zcp3dq4sgIsbQlLqofsqMPMMbgPYKiwyHU0+eQyHCazTI+caxpafy4uc96xtxPnyKcaetPEH9+uRw5Y4UcQW2xDRfGClqjpl08zxevJNcf9OcUUcaa2F prusak@pawel-rusak',
    ]
  }

  accounts::user { 'klash':
    ensure        => present,
    comment       => 'Karl Klashinsky',
    groups        => [ 'sudo' ],
    uid           => '1005',
    gid           => '1005',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA64tYZhxSScstVpzdPQfN84iuDtYLoqP26PFptWs4TZjoaC0w6CKQv+LzJF/xqoAZjRcyFmTjZGy7NfkkpO4B91/jol+MsLatB0Oqb4H1/98WP2HVaISELOAKpekhaX1XXMLzH3/By8YTpqDfGVa+h3SBbcXZiP8VwuJWt4b1s91WX8OfD6b8HUxIyWU4hOnZ9ZOpb58FC9YGdDGTPqAXozUxtAlmrxBsQo5Vf3tCZf/p+dW/SauBcEhuG2IQQ9Ga3dW/3OsuH92v4kg7RSYR/lnJDfayGo5Mx71nbgl8i7lAXQ8mz+hlkYMOaOTwc4UPoc+o28d1Ue9Y75+Pb0JsBw== klash@sa-nc-spg-177.static.jnpr.net',
    ]
  }

  accounts::user { 'vmahuli':
    ensure        => present,
    comment       => 'Vinay Mahuli',
    groups        => [ 'sudo' ],
    uid           => '1006',
    gid           => '1006',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1Nx27hz2lUUC20DkwFDgPwh3KB5nAkCgKQakkB10da7Ty8ogcJ4DUOrGS9Gl7kdRAByzAgJ6c6kkzuxQv35qUgH6udljgTXIKzjt8gbvQz9udeLQiTxcAnqztqtb/XIEqNRXIQQwtxklxkcUvCAC4qIbd05s01Cr0kZ53+4o36dhN4z2UMFCgeuH9fqdUTUgSa6IlOwc9cjSaAreFrdnX230hzvIcN5LnX3+sp3X8q/xpwMvX5xze/5gXkd1GRQE4SymlGnFC4Et9ueV9H4gSNCARrx+JcicFVObj/A12/sehw2I+HwSdA2jbBOfPdbiYvHfYKtWHe7xBFzslf5pZ vmahuli@noded1',
    ]
  }
  # lint:endignore
}
