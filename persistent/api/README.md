- `conf` the yaml config files to declare and evaluate (using groovy) some variables to be used in gsp (groovy) templates. loaded by name order without subfolders.

- `artifacts` the folder where you can put artifacts (jar, war, aar, etc) to be deployed on server into corresponding folders
 all directories are related to current product.
 for example files from `./repository/conf/*` will go to `/opt/productname/repository/conf/*`

- `templates` the folder similar to artifacts, but contains only files native for wso2 server


actually you can put together `artifacts` and `templates`. we just suggest to split development artifacts from configurations and libraries that belongs to platform.

Note: all `*.gsp` files precessed as groovy templates inside docker images.