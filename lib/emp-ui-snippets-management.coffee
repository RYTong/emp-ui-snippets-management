EmpUiSnippetsmanagementView = require './view/emp-ui-snippets-management-view'
{CompositeDisposable} = require 'atom'
emp = require './exports/emp'

# -------------------use for template management -------------------------
create_snippets_management = (params) ->
  empSnippetsManagementView = new EmpUiSnippetsmanagementView(params)

open_snippets_wizard_panel = (params)->
  # console.log "open_temp_wizard_panel"
  atom.workspace.open(emp.EMP_TEMP_URI)
  # empTmpManagementView.add_new_panel()

snippets_deserializer =
  name: emp.SNIPPETS_WIZARD_VIEW
  version: 1
  deserialize: (state) ->
    console.log "emp ui snippets  deserialize"
    create_snippets_management(state) if state.constructor is Object

atom.deserializers.add(snippets_deserializer)


module.exports = EmpUiSnippetsmanagement =
  empUiSnippetsmanagementView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    atom.workspace.addOpener (uri) ->
      # console.log "emp registerOpener: #{uri}"
      # console.log atom.workspace.activePane
      # console.log atom.workspace.activePane.itemForUri(configUri)
      if uri is emp.EMP_TEMP_URI
        create_snippets_management({uri})



    # @emp_temp_management = new EmpTempManagement()
    # atom.project.cbb_management = @emp_temp_management

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-workspace",
      "emp-ui-snippets-management:snippets-management": -> open_snippets_wizard_panel(emp.DEFAULT_PANEL)

    # Register command that toggles this view
    # @subscriptions.add atom.commands.add 'atom-workspace', 'emp-ui-snippets-management:snippets-management': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @empUiSnippetsmanagementView.destroy()

  serialize: ->
    empUiSnippetsmanagementViewState: @empUiSnippetsmanagementView.serialize()

  toggle: ->
    console.log 'EmpUiSnippetsmanagement was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

module.exports.open_snippets_wizard = open_snippets_wizard_panel
