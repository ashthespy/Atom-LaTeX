pkg = require '../lib/main'
helper = require './helper'
path = require 'path'

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
        expect(pkg.latex.logPanel).toBeDefined()
        expect(pkg.latex.parser).toBeDefined()

  describe 'Builder', ->

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
