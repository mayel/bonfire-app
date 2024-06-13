# What is a Bonfire extension

Extensions in Bonfire are collections of code that introduce new features and enhance the platform's functionality, or explore a different user experience for an existing feature. 

They can range from adding entirely new pages, such as [bonfire_invite_links]() which lets admins create and share invites with usage limit and expiration date, to implementing specific components or widgets. 
An example is [bonfire_editor_milkdown](), which integrates a markdown-first editor for publishing activities. 

Extensions are versatile, they can implement their own schema, database, logic, and components, or they can leverage existing fields, context functions, and UI components, or more commonly, a combination of both.

Bonfire's strength lies in its modular architecture. 
A significant portion of its codebase is included in extensions, each serving specific purposes. 
Moreover, extensions often utilise code from other extensions. 
For instance, [bonfire_common]() and [bonfire_ui_common]() provide a suite of helpers to ease a good amount of tasks.