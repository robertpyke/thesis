Installation Guide
====================

Technologies Used
-------------------

- Ubuntu 12.10
- Ruby 1.9.3
- Rails 3.2.11
- psql (PostgreSQL) 9.1.7
- postgis 1.5.3 (1.5.3-2ubuntu1)
- Git (version control)

Steps
------

1. Install Ubuntu 12.10
2. Update your install
```bash
  sudo apt-get update && sudo apt-get upgrade
```

3. Install Ruby1.9.3
```bash
   sudo apt-get install ruby1.9.3
```

4. Install Bundler (gem)
```bash
  sudo gem1.9.3 install bundler
```

5. Install Git
```bash
  sudo apt-get install git-core
```

6. Git Clone the Repository
```bash
  cd ~/Documents && git clone git://github.com/robertpyke/thesis.git
```

7. Install build-essential packages
```bash
  sudo apt-get install build-essential
```

8. Install postgresql 9.1 and postgis
```bash
  sudo apt-get install postgresql-9.1-postgis
```

9. Install the C postgresql adapter header files
```bash
  sudo apt-get install libpq-dev
```

10. Install gems
```bash
  cd ~/Documents/thesis/webapp/ && bundle install
```

11. Install a JavaScript runtime environment (NodeJS includes the v8 engine)
```bash
  sudo apt-get install nodejs
```
