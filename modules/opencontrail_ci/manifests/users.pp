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
    uid           => '1101',
    gid           => '1101',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8xYbz7ohnFJuo8pvaRmzzRazLAPzGTcwcq848iKx6W9OZWjHMKJ40TiMM4RyeWvjGP68aEkLA6Pgdrxlf1e2rmiIH5il+znLEHslnpA3FjWbRMx5HiXn4ZKmVvFU8uGmXPeevMbHM+YJdxkMjAdf9uV8pA4EmUcsdyxK9oLZFDWsvJEeZXz6Andc+wpYCNh3FNoRO0+lIhuFdzXhf2a9mVqV3TmkgUW4KojH03kEGzudsZ+9ZZuKOe2TevHA58atabSiKQfg7T2q1EmNObpcEacxFiVsmT8DgbkHjN+AftsFulUKPA9kzfSYmfAX238Ib4aSKcvpONPi/RKzh5ee3 kklimonda@noise',
    ]
  }

  accounts::user { 'jluk':
    ensure        => present,
    comment       => 'Jaroslaw Lukow',
    groups        => [ 'sudo' ],
    uid           => '1102',
    gid           => '1102',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvHlOvM6E0vBQHEhBsBsULqtaySmpvi50c4zp8zpWqnl4Br1jc4aABpnmM3EmBAfSlKjbk3LK1N1PHdh7m+ADwpumWX1MnVh1BZqL9Cm5r0pBEfZEpslqWbwsD+ym6RkJ8OdQB7uHjvbQ6xYma4ptEaXaq4UGcWUiLICt4tTEy9P2YZBZfGXv4XWJfBWUr2UhK3MbGOmquk3grB9OmesBZYG88UXcFy15NWEFIXQZsBIEU7jFtAEVpDhVN7aNYH+CvOU7AQ/pgqlRv1+ZTrDehAlp93eONAs9sxxyL2QF7O8v+O2doPiIW2QO3ila852c0qo3udM0DAfWYhbJPYC4PAVuTYdLx18RkLBXlfE8JPFf+UOJ63lQGqTn8vyhUfjpW+3OAY0/xGzZncDvGqbBEQ/N6zQAxAlKOmAb0b5oaUyFLnJ3KrYS3yDAHXl8E98PPDkoIyHQ+pNo3EBLNe91MJ5kMEiL/zU7gc4stNFT6HZQJNObQu200yKBFdjAgYM/BqbUk5YkrQMo3qpTZk1fP2TuLLmJADwEQ7yLZq88J6vqDsQqReQtGn/espwwjTi7uVfoYovdVkmrXw8BpKk9ti5R2+K/eFDCO85MxVpp+2/45noH8+mtDj+FGOx1P+Y0sqVP0ePYbASKngcm0HDVWdg2ZFA7GuE7CtS3EPzgAKw== jaroslaw@jaroslaw-lukow',
    ]
  }

  accounts::user { 'lukasz.lukasiewicz':
    ensure        => present,
    comment       => 'Lukasz Lukasiewicz',
    groups        => [ 'sudo' ],
    uid           => '1103',
    gid           => '1103',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxMPK7PS/rYZ8+kwzuqs25T2S3WcCBV4X8kUwbYx46INV8ocHfE8ZJGLtYeAKkfeZLjpb6z+ksSK/rXlsVlcNHlUm7ikVPXkDtSuzBsn5cYXEtoqXfskWja6JIidQX3qpC/QGLub98siOTVTPEoujRT0TAmkRmRXy2z8mPlz3tWrrLjSQHE3VyczgIv3Zv61VmjIJ6fXyv333R3lh9Lc86pcZrb8p849eJ+VFcX8UKmFgSAgELae8oPbS5f8EHV2mRoKo+F+zxh6TwZLFWSs3yRmuvh5zdFXPOQp52MUzu/hsPfBoiFkV2+V5494jl8Nx7BMZd22ckHmyiefqwGdC7 lukasz.lukasiewicz@HellNote',
    ]
  }

  accounts::user { 'pjrusak':
    ensure        => present,
    comment       => 'Pawel Rusak',
    groups        => [ 'sudo' ],
    uid           => '1104',
    gid           => '1104',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZRWPsDnCCD/krWhk4Zy1SCCR2xS5hGSxW/08TRmWTjenzdrsFEBVKV9gJA5gJVRabebOeRMdBE3bYEHUdU+aCsngkO6Lid/itpUR3u6QKTboxkO7uH+mvVbMIxorl4ufYRk6axL7y3VoGrFwR0Sl9kvtncrjqUcfpNcVrNuP/0EzOKXVp6xhZVAYYLg1/0lCDhq/M2uMG1MHEXk52u6eAZarRqbOE3TU+Zcp3dq4sgIsbQlLqofsqMPMMbgPYKiwyHU0+eQyHCazTI+caxpafy4uc96xtxPnyKcaetPEH9+uRw5Y4UcQW2xDRfGClqjpl08zxevJNcf9OcUUcaa2F prusak@pawel-rusak',
    ]
  }

  accounts::user { 'klash':
    ensure        => present,
    comment       => 'Karl Klashinsky',
    groups        => [ 'sudo' ],
    uid           => '1105',
    gid           => '1105',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA64tYZhxSScstVpzdPQfN84iuDtYLoqP26PFptWs4TZjoaC0w6CKQv+LzJF/xqoAZjRcyFmTjZGy7NfkkpO4B91/jol+MsLatB0Oqb4H1/98WP2HVaISELOAKpekhaX1XXMLzH3/By8YTpqDfGVa+h3SBbcXZiP8VwuJWt4b1s91WX8OfD6b8HUxIyWU4hOnZ9ZOpb58FC9YGdDGTPqAXozUxtAlmrxBsQo5Vf3tCZf/p+dW/SauBcEhuG2IQQ9Ga3dW/3OsuH92v4kg7RSYR/lnJDfayGo5Mx71nbgl8i7lAXQ8mz+hlkYMOaOTwc4UPoc+o28d1Ue9Y75+Pb0JsBw== klash@sa-nc-spg-177.static.jnpr.net',
    ]
  }

  accounts::user { 'vmahuli':
    ensure        => present,
    comment       => 'Vinay Mahuli',
    groups        => [ 'sudo' ],
    uid           => '1106',
    gid           => '1106',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1Nx27hz2lUUC20DkwFDgPwh3KB5nAkCgKQakkB10da7Ty8ogcJ4DUOrGS9Gl7kdRAByzAgJ6c6kkzuxQv35qUgH6udljgTXIKzjt8gbvQz9udeLQiTxcAnqztqtb/XIEqNRXIQQwtxklxkcUvCAC4qIbd05s01Cr0kZ53+4o36dhN4z2UMFCgeuH9fqdUTUgSa6IlOwc9cjSaAreFrdnX230hzvIcN5LnX3+sp3X8q/xpwMvX5xze/5gXkd1GRQE4SymlGnFC4Et9ueV9H4gSNCARrx+JcicFVObj/A12/sehw2I+HwSdA2jbBOfPdbiYvHfYKtWHe7xBFzslf5pZ vmahuli@noded1',
    ]
  }

  accounts::user { 'mmithun':
    ensure        => present,
    comment       => 'Mithun Mistry',
    groups        => [ 'sudo' ],
    uid           => '1107',
    gid           => '1107',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3othGc/CyQYOzkKbGogzcI8NfvfUmMSn4jqPDFh541VYrsImau/wxs08/olgmNttXb6xCYKy8QGAUJF+3852EXNwyaaVyhJjv5N3pwGkKpaCOHOQatonCklmwrmOxJP4XjemjAx3H1RX+6oDujfzjKLq6Mloy4R6DOBIGEvZccAP2WcyIVmu5DloXm676qByR7CZ/ocdW+ZjtJZ8/JptLEEVDvTsD1etXyIjlGPSTAWmzqFICSMTMLfbdVHdXPyNZXhOjDbUUgf5iHF998U2jBoLxa4vycFySg4EwibdY3Ktf5pv0IwfOBjbfh8lVzE6Pd657butJDFrf80gAJRCD mmithun@mmithun-mbp',
    ]
  }

  accounts::user { 'wurbanski':
    ensure        => present,
    comment       => 'Wojciech Urbanski',
    groups        => [ 'sudo' ],
    uid           => '1108',
    gid           => '1108',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChGwBKaBR+W6KxlYenzIcojB0zw0xqjI+3foPiWL5R4eynEvf2g246oynOCCJBWA/xkBTkpy5FAvAA0V1FDUiF/xf5AuPYcR6oe8CBt+1jiQFgeMlo0Mwb7vgrCUtHvedUe3kdO2zYX3lpm9bd/mbnMCCNecja9TsRfdGPZBZuM9tMnf4cGCTelclt2yfxTznf87wH+0iRxDtnSNdtth3GlkblDRWsFsiJzKH4CCAg2sHgwZk6YU8QWt8Z+j4wkm6VfNW8ZetC1Crf/ckrQPNDAKZpt9Bs7IpDgzY8BUf9Dlb4DRpFYaPrZGxGWherQlB1vnZScyMMlvmydLISova2wJzwZVGPaIjHNDrLAEKdA8HBLbsVvEAwGvdf9L9kCm28oz92UstztNXJ8xneX0c2cfEOHxSQkUA/kxpYIgz1bN9wLDod+/TDfNGbulqJ4zoGony5Rz0I8ThyyZuOTyDjkmY9HuTVkfneDPEby1jGkOGQ2k7euHyy8RjLLpd4/ZyxWAeDsWt4aJYKuol5VNUKYiL7ZmUPcrHFhThgLSt4icMcE6dJGAKevZVECB9ZeH7IQgQg/BSQ7eGx8ojZvrc3LWGzSSWJD5Iy8UyyIep0KNfMPZ8bDwT1WdFsgeKXRxAs2nrT1GmDGC4lRRx15dFxsv4hasa9x+v0prfRxMXSBw== wojciech.urbanski@codilime.com'
    ]
  }
  # lint:endignore
}
