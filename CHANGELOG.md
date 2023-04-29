# Changelog for UserRegistryDSC

## [0.1.3] - 2023-04-29
- Changed ValueType property from int to string so that string input is also accepted. String property works for both string and int.
- Corrected verbose output in set method so that it will correctly display the current value.
- Added missing -Valuetype property in set method when creating not existing key so that the Value is generated with the correct valuetype.
- Added workaround for Get method error because the get method cannot return an array of UserReistry objects as UserRegistry object.
  Instead, if there is at least one userprofile with a value not in desired state, the first value that is not correct will be shown.
  Not the most beautiful fix, but the get method will work again. Any ideas for further improvements are welcome!