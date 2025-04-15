# Sai

[![Sai Version](https://img.shields.io/gem/v/sai?style=for-the-badge&logo=rubygems&logoColor=white&logoSize=auto&label=Gem%20Version)](https://rubygems.org/gems/sai)
[![Sai License](https://img.shields.io/github/license/rei-kei/sai-rb?style=for-the-badge&logo=opensourceinitiative&logoColor=white&logoSize=auto)](./LICENSE)
[![Sai Docs](https://img.shields.io/badge/rubydoc-blue?style=for-the-badge&logo=readthedocs&logoColor=white&logoSize=auto&label=docs)](https://rubydoc.info/gems/sai)
[![Sai Open Issues](https://img.shields.io/github/issues-search/rei-kei/sai-rb?query=state%3Aopen&style=for-the-badge&logo=github&logoColor=white&logoSize=auto&label=issues&color=red)](https://github.com/rei-kei/sai-rb/issues?q=state%3Aopen%20)

> [!WARNING]
> Sai is currently under active development and not recommended for production use. The main branch may experience
> force pushes and breaking changes during this development phase. For stable versions, please refer to
> [aaronmallen/sai](https://github.com/aaronmallen/sai).

A powerful color science toolkit for seamless cross-model manipulation.

Sai is a sophisticated color management system built on precise color science principles. It provides a unified 
interface across multiple color models (RGB, HSL, CMYK, CIE Lab, Oklab, and more), allowing operations in any model to 
intelligently propagate throughout the entire color ecosystem.

Key features include cross-model operations, perceptually accurate color comparisons using multiple Delta-E algorithms,
accessibility tools for contrast evaluation, sophisticated color matching, and scientific color analysis with CIE
standards support.

Sai empowers developers to work with colors consistently across different environments and applications. Whether
developing design tools, data visualizations, or accessibility-focused applications, Sai provides both mathematical
precision and an intuitive API for sophisticated color manipulation.

## Alpha Testing Quick Start


Sai can do many more advance colorimetry operations. The guide below is a quick start for the most common use cases.
However your encourage to explore the code base to discover more advanced capabilities
(like customizing observers, illuminants, and color spaces).

### Creating a color (see [Sai::Function](./lib/sai/function.rb))

To create a color its simply a matter of calling the appropriate model function:

```ruby
Sai.rgb(1,2,3)
Sai.hsl(1,2,3)
Sai.cmyk(1,2,3,4)
Sai.oklch(1,2,3)
```

### Enum

In an effort to eliminate "magic" arguments as much as possible we can use `Sai::Enum`
(see [lib/sai/enum](./lib/sai/enum)). The enum has many different access patterns. All of the following are
equivalent:

```ruby
Sai::Enum::Observer::CIE1931
Sai.enum.observer.cie1931
Sai::Enum.dig(:observer, :cie1931)
Sai.enum.dig(:observer, :cie1931)
Sai::Enum[:observer][:cie1931]
Sai.enum[:observer][:cie1931)
```
For the moment most user's will only interface with `Sai::Enum` for

* color space conversions

```ruby
srgb_red = Sai.rgb(255, 0, 0)
aces_red = srgb_red.to_rgb(color_space: Sai.enum.color_space.aces)
```
* formula selection (see [lib/sai/formula](./lib/sai/formula))

```ruby
text = Sai.rgb(0, 0, 0)
background = Sai.rgb(255, 255, 255)
text.contrast_ratio(background, formula: Sai::Enum::Formula::Contrast::WCAG)
```

### Color math operations

There are several math operations that can be performed on colors
(See [Sai::Channel::Management](./lib/sai/channel/management.rb),
and [Sai::Channel::MethodGenerator](./lib/sai/channel/method_generator.rb))

```ruby
rgb = Sai.rgb(128, 128, 128)
rgb = rgb.with_red_contracted_by(2) # => rgb(64, 128, 128)
rgb = rgb.with_green_decremented_by(1) # => rgb(64, 127, 128)
rgb = rgb.with_blue_incremented_by(2) # => rgb(64, 127, 130)
rgb = rgb.with_red_scaled_by(2) # => rgb(128, 127, 130)
```

There are a few nuances here though. For example hue channels (HSL, HSV, LCH, etc...) are circular channels so the
channel will spin back around to its start point when it's maximum value is exceeded:

```ruby
hsl = Sai.hsl(360, 50, 50)
hsl.increment_hue_by(10) # => hsl(10, 50, 50)
```

### Dealing with Opacity

Opacity is treated like an additional channel for the **most** part and shares most of the same mathematical properties:

```ruby
rgb = Sai.rgb(128, 128, 128).with_opacity(50) # => rgba(128, 128, 128, 50%)
rgb = rgb.with_opacity_incremented_by(2) # => rgba(128, 128, 128, 52%)
rgb = rgb.with_opacity_decremented_by(2) # => rgba(128, 128, 128, 50%)
```

Opacity can the be "applied" to the color via:

```ruby
opaque_rgb = rgb.with_opacity_flattened # => rgb(64, 64, 64)
```

### Unified Model

Model's are "unified"
(see [Sai::Model::Core::Introspection](./lib/sai/model/core/introspection.rb) and
[Sai::Model::Core::Derivation](./lib/sai/model/core/derivation.rb)) what this means is you can do things like:

```ruby
rgb = Sai.rgb(128, 128, 128)
rgb = rgb.with_cyan_incremented_by(2) # => rgb(125, 128, 128)
rgb = rgb.with_hue_scaled_by(2) # => rgb(128, 125, 125)

cmyk = Sai.cmyk(1,2,3,4)
cmym.red #=> 242
```

### Converting to other models

You can convert one model to another model via:

```ruby
red = Sai.rgb(255, 0, 0)
red.to_hsl # => hsl(0, 100, 50)
```
You can also do advanced color space conversions:

```ruby
rgb = Sai.rgb(1,2,3, color_space: Sai::Enum::ColorSpace::SRGB)
rgb = rgb.to_rgb(color_space: Sai::Enum::ColorSpace::ACES)
hsl = rgb.to_hsl(color_space: Sai::Enum::ColorSpace::ADOBE_RGB_1998)
```
see [Sai::Model::Core::Conversion](./lib/sai/model/core/conversion.rb)

### Accessibility

There are several accessibility features that can be utilized
(see [Sai::Model::Core::Contrast](./lib/sai/model/core/contrast.rb))

```ruby
text = Sai.rgb(0,0,0)
background = Sai.rgb(255, 255, 255)
text.sufficient_contrast_for_aa?(background) # => true
text.sufficient_contrast_for_body_text?(background) # => true
```

### Color Comparison Operations

There are several comparison opperations you can do with colors
(see [Sai::Model::Core::Comparison](./lib/sai/model/core/comparison.rb))

```ruby
rgb = Sai.rgb(0, 0, 0)
hsl = Sai.hsl(0, 0, 0)
cmyk = Sai.cmyk(100, 100, 100, 0)
oklch = Sai.oklch(25, 10, 10)

rgb.closest_match(hsl, cmyk, oklch) # => hsl(0, 0, 0)
rgb.perceptually_equivalent?(hsl) # => true
```