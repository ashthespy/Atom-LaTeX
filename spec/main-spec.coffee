path = require 'path'
pkg = require '../lib/main'
helper = require './helper'


describe 'Atom-LaTeX', ->
  beforeEach ->
    waitsForPromise ->
      return helper.activatePackages()

  describe 'Package', ->
    describe 'when package initialized', ->
      it 'has Atom-LaTeX main object', ->
        expect(pkg.latex).toBeDefined()
        expect(pkg.latex.builder).toBeDefined()
        expect(pkg.latex.manager).toBeDefined()
        expect(pkg.latex.viewer).toBeDefined()
        expect(pkg.latex.server).toBeDefined()
        expect(pkg.latex.panel).toBeDefined()
        expect(pkg.latex.parser).toBeDefined()
        expect(pkg.latex.locator).toBeDefined()
        expect(pkg.latex.logger).toBeDefined()
        expect(pkg.latex.cleaner).toBeDefined()

  describe 'Builder', ->
    beforeEach ->
      project = """#{path.dirname(__filename)}#{path.sep}latex_project"""
      atom.project.setPaths [project]
      pkg.latex.mainFile = """#{project}#{path.sep}main.tex"""

    describe 'build-after-save feature', ->
      builder = builder_ = undefined

      beforeEach ->
        builder = jasmine.createSpyObj 'Builder', ['build']
        builder_ = pkg.latex.builder
        pkg.latex.builder = builder

      afterEach ->
        pkg.latex.builder = builder_
        helper.restoreConfigs()

      it 'compile if current file is a .tex file', ->
        helper.setConfig 'atom-latex.build_after_save', true
        project = """#{path.dirname(__filename)}#{path.sep}latex_project"""
        waitsForPromise -> (atom.workspace.open(
          """#{project}#{path.sep}input.tex""").then (editor) ->
            Promise.resolve editor.save()
          ).then () ->
            expect(builder.build).toHaveBeenCalled()

      it 'does nothing if config disabled', ->
        helper.setConfig 'atom-latex.build_after_save', false
        project = """#{path.dirname(__filename)}#{path.sep}latex_project"""
        waitsForPromise -> (atom.workspace.open(
          """#{project}#{path.sep}input.tex""").then (editor) ->
            Promise.resolve editor.save()
          ).then () ->
            expect(builder.build).not.toHaveBeenCalled()

      it 'does nothing if current file is not a .tex file', ->
        helper.setConfig 'atom-latex.build_after_save', true
        project = """#{path.dirname(__filename)}#{path.sep}latex_project"""
        waitsForPromise -> (atom.workspace.open(
          """#{project}#{path.sep}dummy.file""").then (editor) ->
            Promise.resolve editor.save()
          ).then () ->
            expect(builder.build).not.toHaveBeenCalled()

    describe 'toolchain feature', ->
      binCheck = binCheck_ = undefined

      beforeEach ->
        binCheck_ = pkg.latex.builder.binCheck
        spyOn(pkg.latex.builder, 'binCheck')

      afterEach ->
        pkg.latex.builder.binCheck = binCheck_
        helper.restoreConfigs()

      it 'generates latexmk command when enabled auto', ->
        helper.setConfig 'atom-latex.toolchain', 'auto'
        helper.unsetConfig 'atom-latex.latexmk_param'
        pkg.latex.builder.binCheck.andReturn(true)
        pkg.latex.builder.setCmds()
        expect(pkg.latex.builder.cmds[0]).toBe('latexmk -synctex=1 \
          -interaction=nonstopmode -file-line-error -pdf main')

      it 'generates custom command when enabled auto but without binary', ->
        helper.setConfig 'atom-latex.toolchain', 'auto'
        helper.unsetConfig 'atom-latex.compiler'
        helper.unsetConfig 'atom-latex.bibtex'
        helper.unsetConfig 'atom-latex.compiler_param'
        helper.unsetConfig 'atom-latex.custom_toolchain'
        pkg.latex.builder.binCheck.andReturn(false)
        pkg.latex.builder.setCmds()
        expect(pkg.latex.builder.cmds[0]).toBe('pdflatex -synctex=1 \
          -interaction=nonstopmode -file-line-error main')
        expect(pkg.latex.builder.cmds[1]).toBe('bibtex main')

      it 'generates latexmk command when enabled latexmk toolchain', ->
        helper.setConfig 'atom-latex.toolchain', 'latexmk toolchain'
        helper.unsetConfig 'atom-latex.latexmk_param'
        pkg.latex.builder.binCheck.andReturn(true)
        pkg.latex.builder.setCmds()
        expect(pkg.latex.builder.cmds[0]).toBe('latexmk -synctex=1 \
          -interaction=nonstopmode -file-line-error -pdf main')

      it 'generates custom command when enabled custom toolchain', ->
        helper.setConfig 'atom-latex.toolchain', 'custom toolchain'
        helper.unsetConfig 'atom-latex.compiler'
        helper.unsetConfig 'atom-latex.bibtex'
        helper.unsetConfig 'atom-latex.compiler_param'
        helper.unsetConfig 'atom-latex.custom_toolchain'
        pkg.latex.builder.binCheck.andReturn(false)
        pkg.latex.builder.setCmds()
        expect(pkg.latex.builder.cmds[0]).toBe('pdflatex -synctex=1 \
          -interaction=nonstopmode -file-line-error main')
        expect(pkg.latex.builder.cmds[1]).toBe('bibtex main')

    describe '::build', ->
      execCmd = execCmd_ = open = open_ = undefined

      beforeEach ->
        waitsForPromise -> atom.packages.activatePackage('status-bar')
        open = jasmine.createSpy('open')
        stdout = jasmine.createSpy('stdout')
        execCmd = jasmine.createSpy('execCmd').andCallFake((cmd, cwd, fn) ->
          fn()
          return stdout:
            on: (data, fn) ->
              stdout(data, fn)
        )
        open_ = pkg.latex.viewer.openViewerNewWindow
        pkg.latex.viewer.openViewerNewWindow = open
        execCmd_ = pkg.latex.builder.execCmd
        pkg.latex.builder.execCmd = execCmd

      afterEach ->
        pkg.latex.viewer.openViewerNewWindow = open_
        pkg.latex.builder.execCmd = execCmd_
        helper.restoreConfigs()

      it 'should execute all commands sequentially', ->
        helper.setConfig 'atom-latex.toolchain', 'custom toolchain'
        helper.unsetConfig 'atom-latex.compiler'
        helper.unsetConfig 'atom-latex.bibtex'
        helper.unsetConfig 'atom-latex.compiler_param'
        helper.unsetConfig 'atom-latex.custom_toolchain'
        helper.setConfig 'atom-latex.preview_after_build', 'Do nothing'
        pkg.latex.builder.build()
        expect(execCmd.callCount).toBe(4)
        expect(open).not.toHaveBeenCalled()

      it 'should open preview when ready if enabled', ->
        helper.setConfig 'atom-latex.toolchain', 'custom toolchain'
        helper.unsetConfig 'atom-latex.compiler'
        helper.unsetConfig 'atom-latex.bibtex'
        helper.unsetConfig 'atom-latex.compiler_param'
        helper.unsetConfig 'atom-latex.custom_toolchain'
        helper.setConfig 'atom-latex.preview_after_build', true
        pkg.latex.builder.build()
        expect(open).toHaveBeenCalled()

  describe 'Manager', ->
    describe '::fileMain', ->
      it 'should return false when no main file exists in project root', ->
        pkg.latex.mainFile = undefined
        project = """#{path.dirname(__filename)}"""
        atom.project.setPaths [project]
        result = pkg.latex.manager.findMain()
        expect(result).toBe(false)
        expect(pkg.latex.mainFile).toBe(undefined)

      it 'should set main file full path when it exists in project root', ->
        pkg.latex.mainFile = undefined
        project = """#{path.dirname(__filename)}#{path.sep}latex_project"""
        atom.project.setPaths [project]
        result = pkg.latex.manager.findMain()
        relative = path.relative(project, pkg.latex.mainFile)
        expect(result).toBe(true)
        expect(pkg.latex.mainFile).toBe("""#{project}#{path.sep}main.tex""")

    describe '::findAll', ->
      it 'should return all input files recursively', ->
        project = """#{path.dirname(__filename)}#{path.sep}latex_project"""
        atom.project.setPaths [project]
        pkg.latex.mainFile = """#{project}#{path.sep}main.tex"""
        result = pkg.latex.manager.findAll()
        expect(pkg.latex.texFiles.length).toBe(2)
        expect(pkg.latex.bibFiles.length).toBe(0)
