# Auth Service

This microservice implements a token and session based authentication system. This is a Rails API using `jwt` and `devise`.

## Getting Started

Clone the repository and navigate to the project.

Assuming you have PostgreSQL installed and Rails and Ruby installed, preferably with a version manager, execute the following
```
gem install bundler
rake db:create
rake db:migrate
bundle install
```

From here, you should be able to start a server (`rails server`) or access the console (`rails console`)

## Testing

The Postman Workspace can be found here: https://app.getpostman.com/join-team?invite_code=1e2b58da56dd3804430ed1f96e165fd5

Clone the repository and spin up a server in your shell using `rails server`. From here, we can hit the API endpoints through Postman or some other method. Each request does create a user and you may need to delete local users to successfully run tests.


## Performance Testing

Postman allows you to performance test your API with tests. I have run a performance test for the registration endpoint, `POST /api`, with 1000 interations. This performance test is a request in Postman called `Register (performance test)` and has the following performance,
```
50 percentile response time 337 is lower than 1000, the number of iterations is 1000
90 percentile response time 448 is lower than 1000, the number of iterations is 1000
```



## Current State

The following actions are currently supported,
- register `POST /api`
- login `POST /api/login`
- logout `DELETE /api/logout`

Also, the JWT token is not removed from the client side when deleting a session (i.e. logging out).


### Resources

Below is a list of resources
- https://github.com/jwt/ruby-jwt
- https://github.com/heartcombo/devise
- https://hasura.io/blog/best-practices-of-using-jwt-with-graphql/
