# TurboPlay

TurboPlay is a Ruby SDK meant to communicate with an TurboPlay eWallet setup.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'turboplay'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install turboplay

## Initialization

The TurboPlay SDK can either be initialized on a global level, or a on client basis. However, initializing on a global level is not necessarily what you want and won't be thread-safe. If using Rails, Sticking a `client` method in your `ApplicationController` will probably be a better solution than using an initializer as shown below.

In the end, the choice is yours and the optimal solution depends on your needs.

### Global init

```ruby
# config/initializers/turboplay.rb
TurboPlay.configure do |config|
  config.access_key = ENV['TURBOPLAY_ACCESS_KEY']
  config.secret_key = ENV['TURBOPLAY_SECRET_KEY']
  config.base_url   = ENV['TURBOPLAY_BASE_URL']
end
```

If initialized this way, the `TurboPlay` classes can be used without specifying the client.

```ruby
user = TurboPlay::User.find(provider_user_id: 'some_uuid')
```

### Logging

The Ruby SDK comes with the possibility to log requests to the eWallet. For example, within a Rails application, the following can be defined:

```ruby
# config/initializers/turboplay.rb
TurboPlay.configure do |config|
  config.access_key = ENV['TURBOPLAY_ACCESS_KEY']
  config.secret_key = ENV['TURBOPLAY_SECRET_KEY']
  config.base_url   = ENV['TURBOPLAY_BASE_URL']
  config.logger     = Rails.logger
end
```

This would provide the following in the logs:

```
[TurboPlay] Request: POST login
User-Agent: Faraday v0.13.1
Authorization: [FILTERED]
Accept: application/vnd.turboplay.v1+json
Content-Type: application/vnd.turboplay.v1+json

{"provider_user_id":"aeab0d51-b3d9-415d-98ef-f9162903f024"}

[TurboPlay] Response: HTTP/200
Connection: close
Server: Cowboy
Date: Wed, 14 Feb 2018 04:35:52 GMT
Content-Length: 140
Content-Type: application/vnd.turboplay.v1+json; charset=utf-8
Cache-Control: max-age=0, private, must-revalidate

{"version":"1","success":true,"data":{"object":"authentication_token","authentication_token":[FILTERED]}}
```

### Client init

With this approach, the client needs to be passed in every call and will be used as the call initiator.

```ruby
client = TurboPlay::Client.new(
  access_key: ENV['TURBOPLAY_ACCESS_KEY'],
  secret_key: ENV['TURBOPLAY_SECRET_KEY'],
  base_url:   ENV['TURBOPLAY_BASE_URL']
)

user = TurboPlay::User.find(provider_user_id: 'some_uuid', client: client)
```

## Usage

All the calls below will communicate with the TurboPlay wallet specified in the `base_url` configuration. They will either return an instance of `TurboPlay:Error` or of the appropriate model (`User`, `Balance`, etc.), see [the list of models](#models) for more information.

__The method `#error?` can be used on any model to check if it's an error or a valid result.__

### Managing Users

#### Find

Retrieve a user from the eWallet API.

```ruby
user = TurboPlay::User.find(
  provider_user_id: 'some_uuid'
)
```

Returns either:
- An `TurboPlay::User` instance
- An `TurboPlay::Error` instance

#### Create

Create a user in the eWallet API database. The `provider_user_id` is how a user is identified and cannot be changed later on.

```ruby
user = TurboPlay::User.create(
  provider_user_id: 'some_uuid',
  username: 'john@doe.com',
  metadata: {
    first_name: 'John',
    last_name: 'Doe'
  }
)
```

Returns either:
- An `TurboPlay::User` instance
- An `TurboPlay::Error` instance

#### Update

Update a user in the eWallet API database. All fields need to be provided and the values in the eWallet database will be replaced with the sent ones (behaves like a HTTP `PUT`). Sending `metadata: {}` in the request below would remove the `first_name` and `last_name` fields for example.

```ruby
user = TurboPlay::User.update(
  provider_user_id: 'some_uuid',
  username: 'jane@doe.com',
  metadata: {
    first_name: 'Jane',
    last_name: 'Doe'
  }
)
```

Returns either:
- An `TurboPlay::User` instance
- An `TurboPlay::Error` instance

### Managing Sessions

#### Login

Login a user and retrieve an `authentication_token` that can be passed to a mobile client to make calls to the eWallet API directly.

```ruby
auth_token = TurboPlay::User.login(
  provider_user_id: 'some_uuid'
)
```

Returns either:
- An `TurboPlay::AuthenticationToken` instance
- An `TurboPlay::Error` instance

### Managing Balances

- [All](#All)
- [Credit](#Credit)
- [Debit](#Debit)

#### All

Retrieve a list of addresses (with only one address for now) containing a list of balances.

```ruby
address = TurboPlay::Balance.all(
  provider_user_id: 'some_uuid'
)
```

Returns either:
- An `TurboPlay::Address` instance
- An `TurboPlay::Error` instance

#### Credit

Transfer the specified amount (as an integer, down to the `subunit_to_unit`) from the master wallet to the specified user's wallet. In the following methods, an idempotency token is used to ensure that one specific credit/debit occurs only once. The implementer is responsible for ensuring that those idempotency tokens are unique - sending the same one two times will prevent the second transaction from happening.

```ruby
address = TurboPlay::Balance.credit(
  provider_user_id: 'some_uuid',
  token_id: 'PLAY:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

To use the primary balance of a specific account instead of the master account's as the sending balance, specify an `account_id`:

```ruby
address = TurboPlay::Balance.credit(
  account_id: 'account_uuid',
  provider_user_id: 'some_uuid',
  token_id: 'PLAY:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

#### Debit

Transfer the specified amount (as an integer, down to the `subunit_to_unit`) from the specified user's wallet back to the master wallet.

```ruby
address = TurboPlay::Balance.debit(
  provider_user_id: 'some_uuid',
  token_id: 'PLAY:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

To use the primary balance of a specific account instead of the master account as the receiving balance, specify an `account_id`:

```ruby
address = TurboPlay::Balance.debit(
  account_id: 'account_uuid',
  provider_user_id: 'some_uuid',
  token_id: 'PLAY:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

By default, points won't be burned and will be returned to the account's primary balance (either the master's balance or the account's specified with `account_id`). If you wish to burn points, send them to a burn address. By default, a burn address identified by `'burn'` is created for each account which can be set in the `burn_balance_identifier` field:

```ruby
address = TurboPlay::Balance.debit(
  account_id: 'account_uuid',
  burn_balance_identifier: 'burn',
  provider_user_id: 'some_uuid',
  token_id: 'PLAY:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

### Getting settings

#### All

Retrieve the settings from the eWallet API.

```ruby
settings = TurboPlay::Setting.all
```

Returns either:
- An `TurboPlay::Setting` instance
- An `TurboPlay::Error` instance


### Listing transactions

#### Params

Some parameters can be given to the two following methods to customize the returned results. With them, the list of results can be paginated, sorted and searched.

- `page`: The page you wish to receive.
- `per_page`: The number of results per page.
- `sort_by`: The sorting field. Available values: `id`, `status`, `from`, `to`, `created_at`, `updated_at`
- `sort_dir`: The sorting direction. Available values: `asc`, `desc`
- `search_term`: A term to search for in ALL of the searchable fields. Conflict with `search_terms`, only use one of them. See list of searchable fields below (same as `search_terms`).
- `search_terms`: A hash of fields to search in:  

```ruby
{
  search_terms: {
    from: "address_1"
  }
}
```

Available values: `id`, `idempotency_token`, `status`, `from`, `to`

#### All

Get the list of transactions from the eWallet API.

```ruby
transaction = TurboPlay::Transaction.all
```

Returns either:
- An `TurboPlay::List` instance of `TurboPlay::Transaction` instances
- An `TurboPlay::Error` instance

Parameters can be specified in the following way:

```ruby
transaction = TurboPlay::Transaction.all(params: {
  page: 1,
  per_page: 10,
  sort_by: 'created_at',
  sort_dir: 'desc',
  search_terms: {
    from: "address_1",
    to: "address_2",
    status: "confirmed"
  }
})
```

#### All for user

Get the list of transactions for a specific provider user ID from the eWallet API.

```ruby
transaction = TurboPlay::Transaction.all(
  params: {
    provider_user_id: "some_uuid"
  }
)
```

Returns either:
- An `TurboPlay::List` instance of `TurboPlay::Transaction` instances
- An `TurboPlay::Error` instance

Parameters can be specified in the following way:

```ruby
transaction = TurboPlay::Transaction.all(params: {
  provider_user_id: "some_uuid",
  page: 1,
  per_page: 10,
  sort_by: 'created_at',
  sort_dir: 'desc',
  search_terms: {
    from: "address_1",
    status: "confirmed"
  }
})
```

Since those transactions are already scoped down to the given user, it is NOT POSSIBLE to specify both `from` AND `to` in the `search_terms`. Doing so will result in the API ignoring both of those fields for the search.

## Models

Here is the list of all the models available in the SDK with their attributes.

### `TurboPlay::Address`

Attributes:
- `address` (string)
- `balances` (array of TurboPlay::Balance)

### `TurboPlay::Balance`

Attributes:
- `amount` (integer)
- `minted_token` (TurboPlay::MintedToken)

### `TurboPlay::AuthenticationToken`

Attributes:
- `authentication_token` (string)

### `TurboPlay::Pagination`

Attributes
- `per_page` (integer)
- `current_page` (integer)
- `first_page?` (boolean)
- `last_page?` (boolean)

### `TurboPlay::List`

Attributes:
- `data` (array of models)
- `pagination` (TurboPlay::Pagination)

### `TurboPlay::MintedToken`

Attributes:
- `symbol` (string)
- `name` (string)
- `subunit_to_unit` (integer)

### `TurboPlay::User`

Attributes:
- `id` (string)
- `username` (string)
- `provider_user_id` (string)
- `metadata` (hash)

### `TurboPlay::Exchange`

- `rate` (integer)

### `TurboPlay::TransactionSource`

- `address` (string)
- `amount` (integer)
- `minted_token` (`TurboPlay::MintedToken`)

### `TurboPlay::Transaction`

- `id` (string)
- `idempotency_token` (string)
- `amount` (integer)
- `minted_token` (`TurboPlay::MintedToken`)
- `from` (`TurboPlay::TransactionSource`)
- `to` (`TurboPlay::TransactionSource`)
- `exchange` (`TurboPlay::Exchange`)
- `status` (string)
- `created_at` (string)
- `updated_at` (string)

### `TurboPlay::Error`

Attributes:
- `code` (string)
- `description` (string)
- `messages` (hash)

## Live Tests

Live tests are recorded using VCR. However, they have been updated to hide any access/secret key which means deleting them and re-running the live tests will fail. It is first required to update the `spec/env.rb` file with real keys. Once the VCR records have been re-generated, do not forget to replace the `Authorization` header in all of them using the base64 encoding of fake access and secret keys.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
