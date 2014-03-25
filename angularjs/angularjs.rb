##################
### References ###
##################
# http://www.localytics.com/blog/2014/a-year-on-angular-on-rails-a-retrospective/
# http://www.amberbit.com/blog/2014/1/20/angularjs-templates-in-ruby-on-rails-assets-pipeline/
# http://gaslight.co/blog/4-lessons-learned-doing-angular-on-rails
# http://blog.zerosum.org/2014/01/17/rails-angular-jasmine.html
# https://shellycloud.com/blog/2013/10/how-to-integrate-angularjs-with-rails-4

#################
#### READ ME ####
#################
README = <<'EOR'

==============================================================================

README: 

  inside layout template include:
    <html ng-app="<%= @ng_app || 'app' %>">

    <%= javascript_include_tag "app/#{@ng_app || 'app'}" %>

  Don't forget to disable/remove turbolinks from your:
    Gemfile
    application.js

  Check config/environments/production.rb for `config.assets.js_compressor = :uglifier` and remove it 

EOR

#################
### Gems list ###
#################
gem 'angularjs-rails'

gem_group :development do
  gem 'jasmine-rails'
end

####################################
### Directory and File structure ###
####################################
%w{controllers services factories templates filters directives}.each do |directory|
  file "app/assets/javascripts/app/#{directory}/.keep"
  file "spec/javascripts/#{directory}/.keep"
end

file 'app/assets/javascripts/app/base.js', <<-CODE
#= require angular
#= require angular-route
#= require angular-resource
CODE

file 'app/assets/javascripts/app/app.js.coffee.erb', <<-CODE
#= require ./base
#= require_tree .
#= require_self

angular.module('app', [
  'ngRoute'
  # 'app.factories',
  # 'app.services',
  # 'app.directives',
  # 'app.filters',
  # 'app.controllers'
]).
config ['$routeProvider', ($routeProvider) ->
  # $routeProvider.when '/', templateUrl: '<%= asset_path("app/templates/index.html") %>', controller: 'Main'
  $routeProvider.otherwise redirectTo: '/'
]
CODE

file 'spec/javascripts/spec_helper.coffee', <<-CODE
#= require app/app
#= require angular-mocks
#= require sinon
#= require jasmine-sinon
 
beforeEach(module('AngularApp'))
 
beforeEach inject (_$httpBackend_, _$compile_, $rootScope, $controller, $location, $injector, $timeout) ->
  @scope = $rootScope.$new()
  @http = _$httpBackend_
  @compile = _$compile_
  @location = $location
  @controller = $controller
  @injector = $injector
  @timeout = $timeout
  @model = (name) =>
    @injector.get(name)
  @eventLoop =
    flush: =>
      @scope.$digest()
  @sandbox = sinon.sandbox.create()
 
afterEach ->
  @http.resetExpectations()
  @http.verifyNoOutstandingExpectation()
CODE

#######################
### Configure Rails ###
#######################
environment "config.assets.precompile << 'app/*.js*'", env: 'production'
environment "config.assets.js_compressor = Uglifier.new(mangle: false)", env: 'production'

generate 'jasmine_rails:install'

puts README
