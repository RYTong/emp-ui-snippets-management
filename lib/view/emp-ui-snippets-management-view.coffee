{$, $$, ScrollView} = require 'atom-space-pen-views'
remote = require 'remote'
dialog = remote.require 'dialog'
fs = require 'fs'
path = require 'path'

emp = require '../exports/emp'
GeneralPanel = require './general-panel'
CbbAddUiSnippetsView = require './add-ui-snippets-view'
CbbShowUiSnippetsView = require './cbb-show-ui-snippets-view'
SnippetDetailView = require './cbb-ui-snippet-detail-view'

module.exports =
class EmpTmpManagementView extends ScrollView

  @content: ->
    @div class: 'emp-ui-snippets-management pane-item', tabindex: -1, =>
      @div class: 'config-menu', outlet: 'sidebar', =>
        @div outlet:"emp_logo", class: 'atom-banner'
        @ul class: 'panels-menu nav nav-pills nav-stacked', outlet: 'panelMenu', =>
          @div class: 'panel-menu-separator', outlet: 'menuSeparator'
        @div class: 'button-area', =>
          @button class: 'btn btn-default icon icon-link-external', outlet: 'openDotAtom', 'Open ~/.template'
      @div class: 'panels', outlet: 'panels'


  initialize: ({@uri, activePanelName}={}) ->
    super
    console.log "snippets wizard view"
    @panelToShow = activePanelName
    atom.project.snippets_path = path.join __dirname, '../../snippets/'

    process.nextTick => @initializePanels()

  initializePanels: ->
    return if @panels.size > 0
    # console.log  atom.project.cbb_management

    @panelsByName = {}
    @on 'click', '.panels-menu li a, .panels-packages li a', (e) =>
      @showPanel($(e.target).closest('li').attr('name'))

    @addCorePanel emp.DEFAULT_PANEL, 'paintcan', -> new GeneralPanel("1")
    @addCorePanel emp.EMP_SHOW_UI_LIB, 'package', -> new CbbShowUiSnippetsView("2")
    @addCorePanel emp.EMP_UI_LIB, 'plus', -> new CbbAddUiSnippetsView("3")

    @addOtherPanel emp.EMP_SNIPPET_DETAIL, -> new SnippetDetailView()

    @showPanel(@panelToShow) if @panelToShow
    @showPanel(emp.DEFAULT_PANEL) unless @activePanelName
    @sidebar.width(@sidebar.width()) if @isOnDom()

  addCorePanel: (name, iconName, panel) ->
    panelMenuItem = $$ ->
      @li name: name, =>
        @a class: "icon icon-#{iconName}", name
    @menuSeparator.before(panelMenuItem)
    @addPanel(name, panelMenuItem, panel)

  addPanel: (name, panelMenuItem, panelCreateCallback) ->
    @panelCreateCallbacks ?= {}
    @panelCreateCallbacks[name] = panelCreateCallback
    @showPanel(name) if @panelToShow is name

  addOtherPanel: (name, panelCreateCallback) ->
    # @panelDetail ? = {}
    @addPanel name, null, =>
      panelCreateCallback()



  getOrCreatePanel: (name) ->
    panel = @panelsByName?[name]
    unless panel?
      if callback = @panelCreateCallbacks?[name]
        panel = callback()
        @panelsByName ?= {}
        @panelsByName[name] = panel
        delete @panelCreateCallbacks[name]
    panel

  showPanel: (name, opts, detail) ->
    if panel = @getOrCreatePanel(name)
      panel.refresh_detail?(detail)
      @panels.children().hide()
      @panels.append(panel) unless $.contains(@panels[0], panel[0])
      panel.beforeShow?(opts)
      panel.show()
      panel.focus()
      @makePanelMenuActive(name)
      @activePanelName = name
      @panelToShow = null
    else
      @panelToShow = name

  makePanelMenuActive: (name) ->
    @sidebar.find('.active').removeClass('active')
    @sidebar.find("[name='#{name}']").addClass('active')


  # Returns an object that can be retrieved when package is activated
  serialize: ->
    deserializer: emp.TEMP_WIZARD_VIEW
    version: 1
    activePanelName: @activePanelName ? @panelToShow
    uri: @uri


  focus: ->
    super
    # Pass focus to panel that is currently visible
    for panel in @panels.children()
      child = $(panel)
      if child.isVisible()
        if view = child.view()
          view.focus()
        else
          child.focus()
        return

  getUri: ->
    @uri

  getTitle: ->
    "Template Management View"

  getIconName: ->
    "tools"

  getURI: ->
    @uri


  isEqual: (other) ->
    other instanceof EmpTmpManagementView


  remove_loading: ->
    @loadingElement.remove()
