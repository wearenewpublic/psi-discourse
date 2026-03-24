# Overview

Our goal is to create a discourse plugin that replicates the core functionality of the PSI product.
PSI is here: https://github.com/wearenewpublic/psi-product
(You probably want to add it as a submodule so you can more easily refer to it)

This consists of multiple parts:
* Design Skinning - make conversations visually resemble the styling here: https://www.figma.com/design/5vqFJlKdA6UAQJeXYlMQW2/PSI-Stage-2?node-id=5279-126329&t=zmdjTVJ0DGun53y3-4
    * Broader component styling: https://www.figma.com/design/5vqFJlKdA6UAQJeXYlMQW2/PSI-Stage-2?node-id=7533-84469&t=zmdjTVJ0DGun53y3-4
    * To begin with, just do whatever style skinning is easy. We don't need everything exactly the same.
* Comment Slider - allow conversations where each top level reply sets a slider position saying where they stand on a five-point scale
    * Scale items are : Strongly no, No with reservations, It's complicated, Yes with reservations, Strongly Yes
    * Slider widget appears above the conversation. Once you've voted, it's replaced with a bar chart showing votes. Also option to vote without commenting.
    * When enabled, conversations are limited to one top level reply per person
    * Designs: https://www.figma.com/design/5vqFJlKdA6UAQJeXYlMQW2/PSI-Stage-2?node-id=40-16961&t=zmdjTVJ0DGun53y3-4
* Badging of editorial staff with centrally-determine labels (e.g. Journalist)
* Only admins can create conversations
* Other features to come later, once you've done that stuff

Some of this can probably be done by enabling existing plugins. Some of this we'll need to do ourselves.

I assume we'll want stages like this:
* Confirm we can run everything locally
* Set up E2E testing so that we can automatically verify that things we've build work and take screenshots
* Implement basic theming so conversation looks mostly like the figma design
* Implement comment slider
* Get this working in a container hosted on DigitalOcean

