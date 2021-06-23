[![glopos on pub.dev](https://badgen.net/pub/v/glopos)][glopos_pub]
[![LICENSE](https://badgen.net/pub/license/glopos)][license]
[![CI](https://github.com/blaugold/glopos/actions/workflows/CI.yaml/badge.svg)][ci]

<p align="center">
  <img style="width: 20rem;" src="https://raw.githubusercontent.com/blaugold/glopos/main/docs/assets/Icon.svg"/>
</p>

# glopos

`glopos` is a UI library which allows you to create visual effects which
leverage a `Scene` of `SceneElement`s and `Window`s into that `Scene`.

A `Scene` is a `Widget` that establishes a coordinate system for `SceneElement`s and provides a collection of `SceneElement`s in this coordinates system to the `Window`s in it's subtree.

`SceneElement`s are layed out in the `Scene` but do not provide a visual representation. That is the role of the `WindowDelegate`. Every `Window` has a `WindowDelegate` which is responsible for providing a visual representation for each `SceneElement`. Two `Window`s can have distinct `WindowDelegate`s which represent the overall `Scene` in a completely different way.

A `Window` is `Widget` which can be positioned anywhere in the subtree of a `Scene` though the normal Flutter layout system. It's position relative to the `Scene` coordinate system determines which part of the `Scene` is visible through it.

## Prebuilt effects

The library also contains effects built on top of the core components:

- `Spotlight`: Illuminate parts of the UI through a globally positioned spotlight.

## Getting Started

Get started by playing with the examples and by taking a look at their source code (examples contain links). The [example app] has been built for the web and can be [opened in any browser][example app live demo]. 

[glopos_pub]: https://pub.dev/packages/glopos
[license]: https://github.com/blaugold/glopos/blob/main/packages/glopos/LICENSE
[ci]: https://github.com/blaugold/glopos/actions/workflows/CI.yaml
[example app]: https://github.com/blaugold/glopos/tree/main/packages/glopos/example
[example app live demo]: https://blaugold.github.io/glopos/glopos_example/index.html
