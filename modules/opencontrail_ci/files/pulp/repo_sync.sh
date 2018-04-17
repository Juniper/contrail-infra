for i in centos74 centos74-updates centos74-extras centos74-epel; do
    pulp-admin rpm repo sync run --bg --repo-id=$i;
done
