These scripts are used to package and publish deb to DynamicX private server.

```sh
# require secret environment variables
init.sh $REPO_URL
package.sh [$BRANCH_NAME] [multi]
publish.sh [$BRANCH_NAME]
```

Tested on ubuntu with noetic & melodic