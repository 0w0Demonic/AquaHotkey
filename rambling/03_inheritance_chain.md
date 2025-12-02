# Inheritance Chain

So it turns out you can change a built-in class's base.

I have no idea how I didn't think of that, I never tried because why would
AHK even allow that?

But the realization is bigger than it seems.

## The Setup

What we're going for is abstract classes here. Something that you can assume
supports a certain feature (such as being enumerable through `__Enum()`).
