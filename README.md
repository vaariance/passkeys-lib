# Turborepo Design System starter with Changesets

This is an official React design system starter powered by Turborepo. Versioning and package publishing is handled by [Changesets](https://github.com/changesets/changesets) and fully automated with GitHub Actions.

## Using this example

Run the following command:

```sh
npx create-turbo@latest -e with-changesets
```

## What's inside?

This Turborepo includes the following:

### Apps and Packages

- `docs`: A placeholder documentation site powered by [Next.js](https://nextjs.org/)
- `@acme/core`: core React components
- `@acme/utils`: shared React utilities
- `@acme/tsconfig`: shared `tsconfig.json`s used throughout the monorepo
- `@acme/eslint-config`: ESLint preset

Each package and app is 100% [TypeScript](https://www.typescriptlang.org/).

### Utilities

This Turborepo has some additional tools already setup for you:

- [TypeScript](https://www.typescriptlang.org/) for static type checking
- [ESLint](https://eslint.org/) for code linting
- [Prettier](https://prettier.io) for code formatting

### Useful commands

- `bun run build` - Build all packages and the docs site
- `bun run dev` - Develop all packages and the docs site
- `bun run lint` - Lint all packages
- `bun run changeset` - Generate a changeset
- `bun run clean` - Clean up all `node_modules` and `dist` folders (runs each package's clean script)

### Changing the npm organization scope

The npm organization scope for this design system starter is `@acme`. To change this, it's a bit manual at the moment, but you'll need to do the following:

- Rename folders in `packages/*` to replace `acme` with your desired scope
- Search and replace `acme` with your desired scope
- Re-run `bun run install`

## Versioning and Publishing packages

Package publishing has been configured using [Changesets](https://github.com/changesets/changesets). Please review their [documentation](https://github.com/changesets/changesets#documentation) to familiarize yourself with the workflow.

This example comes with automated npm releases setup in a [GitHub Action](https://github.com/changesets/action). To get this working, you will need to create an `NPM_TOKEN` and `GITHUB_TOKEN` in your repository settings. You should also install the [Changesets bot](https://github.com/apps/changeset-bot) on your GitHub repository as well.

For more information about this automation, refer to the official [changesets documentation](https://github.com/changesets/changesets/blob/main/docs/automating-changesets.md)

### npm

If you want to publish package to the public npm registry and make them publicly available, this is already setup.

To publish packages to a private npm organization scope, **remove** the following from each of the `package.json`'s

```diff
- "publishConfig": {
-  "access": "public"
- },
```

### GitHub Package Registry

See [Working with the npm registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry#publishing-a-package-using-publishconfig-in-the-packagejson-file)
