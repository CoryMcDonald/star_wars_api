# README

## Setup

1. Clone the repository
```sh
git clone https://github.com/CoryMcDonald/star_wars_api.git
```

2. Go into the project
```sh
cd star_wars_api
```

3. Bundle install
```sh
bundle install
```

4. Install yarn
```sh
brew install yarn
```

5. Install yarn packages
```sh
yarn install
```

6. Start the MySQL server
```sh
mysql.server start
```

7. Migrate the database
```sh
bundle exec rails db:create db:migrate RAILS_ENV=<development, test>
```

8. Enable caching (See more in the [caching](#Caching) section)
```sh
rails dev:cache
```

9. Start the server
```sh
bundle exec rails s
```


## Caching
By default, I check to see if the database entry has gotten out of sync by utilizing a low-level cache which expires once every hour. The service call utilizes the etag to determine if the database will need to update. Unfortunately due to a defect in the [deployed SWAPI instance](https://github.com/phalt/swapi/issues/92)  the application will not return 304’s successfully when an `If-Match-None` header is passed to it.

By default Rails **does not cache in development mode**. I recommend that you turn on caching as every request will make a call to the Star Wars API. You can enable the cache by running the following command.

`rails dev:cache`

## Linting

**Ruby**

By default I have configuration in the `.rubocop.yml` file. You can run the linter by the following command
```sh
bundle exec rubocop
```
**Javascript**

The linter is configured vs eslint and is following the standard airbnb config.

```sh
yarn lint
```

## Testing

To run the tests run the following command
```sh
bundle exec rails test
```

# Future Enhancements

**Creating associations between the models**

I initially set out actually creating ActiveRecord associations for these models as they are related in the API. As I was writing the client for the service I realized that it would take a significant more amount of time to do so.

**More elegant API synchronization**

There's a model concern which is called on lookups for any queries. If I was tasked to implement bulk methods like destroy_all and save_all, then I would not use the `after_find` nor the `all` method defined in the concern due to the number of HTTP requests.

In addition if there's a record that gets created in the service it won't get deleted from the application. A simple way to add this would be to modify the `synchronize_records` method to delete the ids that are in the application database but not in the response from SWAPI.

**Decouple model names with API model names**

There currently is exists a tight coupling between what the endpoints SWAPI has defined and what models I have defined in this project. Due to the dynamic calculation of url based on the class name - the model that is going to consume it must be named the same as the model on SWAPI. There could be future work to decouple it however I think this is actually a benefit because our models will be more aligned with the service.

**Support no-script users**

During the initial phone screen it was mentioned that there was hesitation with using javascript due to people who have it disabled by default. This application should be able to fairly easy to adapt. The only thing needed would be to generate JSON links in Rails as opposed to in javascript.
