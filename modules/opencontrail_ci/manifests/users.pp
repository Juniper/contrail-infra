class opencontrail_ci::users {
  accounts::user { 'kklimonda':
    ensure        => present,
    groups        => [ 'sudo' ],
    uid           => '1001',
    gid           => '1001',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8xYbz7ohnFJuo8pvaRmzzRazLAPzGTcwcq848iKx6W9OZWjHMKJ40TiMM4RyeWvjGP68aEkLA6Pgdrxlf1e2rmiIH5il+znLEHslnpA3FjWbRMx5HiXn4ZKmVvFU8uGmXPeevMbHM+YJdxkMjAdf9uV8pA4EmUcsdyxK9oLZFDWsvJEeZXz6Andc+wpYCNh3FNoRO0+lIhuFdzXhf2a9mVqV3TmkgUW4KojH03kEGzudsZ+9ZZuKOe2TevHA58atabSiKQfg7T2q1EmNObpcEacxFiVsmT8DgbkHjN+AftsFulUKPA9kzfSYmfAX238Ib4aSKcvpONPi/RKzh5ee3 krzysztof.klimonda@codilime.com',
    ]
  }

  accounts::user { 'jlukow':
    ensure        => present,
    groups        => [ 'sudo' ],
    uid           => '1002',
    gid           => '1002',
    purge_sshkeys => true,
    sshkeys       => [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvHlOvM6E0vBQHEhBsBsULqtaySmpvi50c4zp8zpWqnl4Br1jc4aABpnmM3EmBAfSlKjbk3LK1N1PHdh7m+ADwpumWX1MnVh1BZqL9Cm5r0pBEfZEpslqWbwsD+ym6RkJ8OdQB7uHjvbQ6xYma4ptEaXaq4UGcWUiLICt4tTEy9P2YZBZfGXv4XWJfBWUr2UhK3MbGOmquk3grB9OmesBZYG88UXcFy15NWEFIXQZsBIEU7jFtAEVpDhVN7aNYH+CvOU7AQ/pgqlRv1+ZTrDehAlp93eONAs9sxxyL2QF7O8v+O2doPiIW2QO3ila852c0qo3udM0DAfWYhbJPYC4PAVuTYdLx18RkLBXlfE8JPFf+UOJ63lQGqTn8vyhUfjpW+3OAY0/xGzZncDvGqbBEQ/N6zQAxAlKOmAb0b5oaUyFLnJ3KrYS3yDAHXl8E98PPDkoIyHQ+pNo3EBLNe91MJ5kMEiL/zU7gc4stNFT6HZQJNObQu200yKBFdjAgYM/BqbUk5YkrQMo3qpTZk1fP2TuLLmJADwEQ7yLZq88J6vqDsQqReQtGn/espwwjTi7uVfoYovdVkmrXw8BpKk9ti5R2+K/eFDCO85MxVpp+2/45noH8+mtDj+FGOx1P+Y0sqVP0ePYbASKngcm0HDVWdg2ZFA7GuE7CtS3EPzgAKw== jaroslaw.lukow@codilime.com',
    ]
  }
}
