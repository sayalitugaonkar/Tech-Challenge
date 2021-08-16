# Tech-Challenge

Magento 2 Installation and Configuration

This project does the task to install and configure Magento with all the necessary technologies for speeding up the
process.
Magento is a E-Commerce Application built with PHP. It’s popular as it provides a lot of
customization via modules and integration with a vast array of technologies including
Elastic-search, Redis, Varnish.
Put together, they make it possible for faster loading times for websites. Similarly, the task
included installation and configuration of said technologies with a custom user(test-ssh) and
group clp.
For viewing Database related information, we are also installing phpmyadmin.
For Operating Systems, Debian Buster was used as mentioned in the documentation.

Tasks done in this project are as below :

1) Install Php-7.4
2) Configure Php-FPM
3) MySQL-8.0 installation and configuration
4) Nginx and Varnish installation and configuration 
5) ElasticSearch and Redis installation
6) Magento installation and configuration
7) PhpMyAdmin


Getting Started

"Add the system information gathered above into a file called hosts.ini in the same directory as this README.md file. "

Additionally, because the path to the file is defined in ansible.cfg, it need not be specified when you run the playbook, so the playbook command could be, simply:

       ansible-playbook setup.yml 

Dependencies Instance running with Debian Buster