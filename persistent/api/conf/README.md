folder for configs.

better to use yaml, however you can use properties or json formats.

all config files loaded in an aphabetical order without subfolders.

in values you can define groovy expressions:

```yaml
local:
  dateTime: "${new Date()}"
  ## you even could reference to previously defined values:
  time: "${ local.dateTime.format('HH:mm:ss') }"
  ## you also could access environment variables through predefined `env` variable
  myFolder: env.WSO2_HOME
```
