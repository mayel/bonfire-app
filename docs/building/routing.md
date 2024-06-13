# Routing

The Bonfire routing system provides a modular and extensible way to define routes for different parts of your application. 
It allows developers to include routes directly from their extensions based on their availability and configuration. 
The routes are organized into pipelines and scopes to handle authentication and authorization requirements.

The Router module is declared in the [router.ex](https://github.com/bonfire-networks/bonfire_spark/blob/main/lib/web/router.ex) file in the [bonfire_spark](https://github.com/bonfire-networks/bonfire_spark) extension.

The `Bonfire.Web.Router.Routes` module defines all the routes for active Bonfire extensions that will be included in the Bonfire app. It also includes routes for GraphQl and AcitvityPub specific endpoints.


In order to add a new route to Bonfire, you need to create a Routes module in your extension. It is usually named as `Project.ExtensionName.Web.Routes` eg. [Bonfire.UI.Social.Routes](https://github.com/bonfire-networks/bonfire_social/blob/main/lib/bonfire_social_web/routes.ex)

The Routes file follows the standard Phoenix/Liveview syntax and structure.

To add a new routes to the Router, you need to add include it to the main Router. 
It is as simple as adding `use_if_enabled(Project.ExtensionName.Web.Routes)` in the [Bonfire.Web.Router.Routes](https://github.com/bonfire-networks/bonfire_spark/blob/main/lib/web/router.ex) file.