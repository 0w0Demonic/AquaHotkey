# Mixins

Recently, I've been looking at a few different programming languages for
coming up with new additions for AquaHotkey. For me, Ruby stood out in
particular because of its elegant design and support for metaprogramming.

```rb
class Swimmy
  def swim
    puts 'splash sploosh!'
  end
end

class Fish
  include Swimmy
end

f := Fish.new
f.swim
```

I just love how Ruby does mixins. You just actively drop in new properties by
using `include` and to apply the given class (or module) as mixin.

AquaHotkey has already come pretty far in terms of things possible, but it's
still pretty hard to use without some prior knowledge or skimming through the
docs first. Which is why I think there should be extensive support for mixins
in the near future.

Let's copy from our friend Ruby:

```ahk
class Enumerable1 {
    ForEach(Action, Args*) {
        for Value in this {
            Action(Value, Args*)
        }
        return this
    }
}

Array.Include(Enumerable1)
```

Yup, this looks much better in comparison.

Also there's `Extend()`, which works exactly the other way.

```ahk
Enumerable1.Extend(Array)
```

Making the use of mixins possible would truly bring a lot of potential, when
done correctly and in a way that is easy to use.

## What Would Need to Change

For now, the only change is that `Class` receives the new methods `.Include()`
and `.Extend()`. I wanted to keep away from adding any properties in the
"main part" of AquaHotkey (`src/Core`), but it's good enough of an addition
to be added in.

Although these two methods are just syntax sugar for things already present
in AquaHotkey, the approach is different. You're *actively* pulling things from,
and pushing onto the specified classes.

This also means the main goal is to include mixins based on the overall
attributes of a class. If you can use a 1-param for-loop on it, you'd want to
include a `Enumerable1` class, for example.

To provide the best experience, AquaHotkeyX would need to be refactored to
accommodate lots of general-use mixins. *How* this should look like, I'm not
sure yet.

Overall, having a rich support for programming with mixins is a small step to
make AHK a little more fun to use.
