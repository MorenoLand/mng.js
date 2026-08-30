# Contributing

Contributions are welcome if they help keep MNG usable, portable, documented, or testable.

## Add or improve an implementation

- Keep each language in its own top-level folder.
- Match the existing behavior: validate the MNG signature, walk bounded chunks, read MHDR metadata, extract embedded PNG frames, and apply FRAM timing.
- Keep version-specific engine code in the relevant version folder, such as `Godot/3.x` or `Godot/4.x`.
- Add or update shared fixtures when behavior changes.
- Document the native API and the compiler or runtime version used.

## Changes

Keep changes focused and avoid changing unrelated implementations. Run the checks available for the language you changed and report the exact command and result. JavaScript, C++, and Go behavior should remain compatible with the existing implementations.

Pull requests should explain the MNG behavior affected, identify the language folders changed, and include fixture or test coverage when practical.

There is no required contribution agreement, fee, attribution, or approval process. Contributions are released under the repository license unless a contributor clearly states otherwise before the contribution is accepted.
