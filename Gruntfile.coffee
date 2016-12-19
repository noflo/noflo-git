module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'
    # BDD tests on Node.js
    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
          grep: process.env.TESTS

    # Coding standards
    coffeelint:
      components: ['components/*.coffee']

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-coffeelint'

  # Our local tasks
  @registerTask 'test', 'Build NoFlo and run automated tests', (target = 'all') =>
    @task.run 'coffeelint'
    if target is 'all' or target is 'nodejs'
      @task.run 'mochaTest'

  @registerTask 'default', ['test']
