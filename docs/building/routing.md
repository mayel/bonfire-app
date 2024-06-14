# Routing

The Bonfire routing system provides a modular and extensible way to define routes for different parts of your application. 
It allows developers to include routes directly from their extensions based on their availability and configuration. 
The routes are organized into pipelines and scopes to handle authentication and authorization requirements.

The Router module is declared in the [router.ex](https://github.com/bonfire-networks/bonfire_spark/blob/main/lib/web/router.ex) file in the [bonfire_spark](https://github.com/bonfire-networks/bonfire_spark) extension.

The `Bonfire.Web.Router.Routes` module defines all the routes for active Bonfire extensions that will be included in the Bonfire app. It also includes routes for GraphQl and AcitvityPub specific endpoints.


In order to add a new route to Bonfire, you need to create a Routes module in your extension. It is usually named as `Project.ExtensionName.Web.Routes` eg. [Bonfire.UI.Social.Routes](https://github.com/bonfire-networks/bonfire_social/blob/main/lib/bonfire_social_web/routes.ex)

The Routes file follows the standard Phoenix/Liveview syntax and structure.

## Add a new route

To add a new routes to the Router, you need to add include it to the main Router. 

You need to clone and enable `bonfire_spark` locally.

> #### Info {: .info}
>
> You need a workaround to be able to enable bonfire_spark locally. We have an open issue about it. You need to clone or rename the extesion from bonfire_spark to bonfire in your extensions folder and subsequentally rename it as bonfire in your deps.flavour.path file.

Once you have bonfire_spark enabled locally, include your new extension router with `use_if_enabled(Project.ExtensionName.Web.Routes)` in the [Bonfire.Web.Router.Routes](https://github.com/bonfire-networks/bonfire_spark/blob/main/lib/web/router.ex) file.

