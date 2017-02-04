module.exports =
  activatePackages: ->
    workspaceElement = atom.views.getView atom.workspace
    packages = ['atom-latex']
    activationPromise = Promise.all packages.map (pkg) ->
      atom.packages.activatePackage pkg
    atom_latex.lazyLoad()
    return activationPromise

  setConfig: (keyPath, value) ->
    @originalConfigs ?= {}
    @originalConfigs[keyPath] ?= atom.config.get keyPath
    atom.config.set keyPath, value

  unsetConfig: (keyPath) ->
    @originalConfigs ?= {}
    @originalConfigs[keyPath] ?= atom.config.get keyPath
    atom.config.unset keyPath

  restoreConfigs: ->
    if @originalConfigs
      for keyPath, value of @originalConfigs
        atom.config.set keyPath, value

  callAsync: (timeout, async, next) ->
    if typeof timeout is 'function'
      [async, next] = [timeout, async]
      timeout = 5000
    done = false
    nextArgs = null

    runs ->
      async (args...) ->
        done = true
        nextArgs = args


    waitsFor ->
      done
    , null, timeout

    if next?
      runs ->
        next.apply(this, nextArgs)
