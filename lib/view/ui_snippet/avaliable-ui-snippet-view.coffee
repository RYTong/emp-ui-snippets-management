{View} = require 'atom-space-pen-views'
emp = require '../../exports/emp'
remote = require 'remote'
dialog = remote.require 'dialog'
path = require 'path'
fs_plus = require 'fs-plus'
# AvailableTypeView = require './ui_snippet/avaliable-ui-type-view'


module.exports =
class AvailablePackageView extends View

  @content: (snippet_path, snippet_file) ->
    snippet_pack = path.basename snippet_file, emp.DEFAULT_SNIPPET_FILE_EXT
    @div class: 'available-package-view col-lg-8', =>
      @div class: 'stats pull-right', =>
        @span class: "stats-item", =>
          @span class: 'icon icon-versions'
      @div class: 'body', =>
        @h4 class: 'card-name', =>
          @a outlet: 'packageName', snippet_pack
        # @span outlet: 'packageDescription', class: 'package-description', tmp_desc

      @div class: 'meta', =>
        @div class: 'meta-controls', =>
          @div outlet: 'buttons', class: 'btn-group', =>
            if emp.EMP_DEFAULT_SNIPPETS.indexOf(snippet_file) < 0
              @button type: 'button', class: 'btn icon icon-trashcan', outlet: 'uninstall_button', click:'do_uninstall', 'Uninstall'
            @button type: 'button', class: 'btn icon icon-repo', outlet: 'detail_utton', click:'show_detail', 'Detail'

  initialize: (@snippet_path, @snippet_file) ->
    @snippet_pack = path.basename snippet_file, emp.DEFAULT_SNIPPET_FILE_EXT

  do_uninstall: ->
    tmp_flag = @show_alert()
    @snippet_file_name = path.join @snippet_path , @snippet_file
    # console.log tmp_flag
    switch tmp_flag
      when 1
        # console.log "1"
        fs_plus.removeSync(@snippet_file_name) unless !fs.existsSync @snippet_file_name
        snippets = require atom.packages.activePackages.snippets.mainModulePath
        snippets.loadAll()
        emp.show_info "删除成功！"
      else return

  do_edit:->
    console.log 'do_edit'
    @fa_view.show_edit_panel(@package_obj)


  show_alert: (replace_con, relative_path, editor) ->
    atom.confirm
      message: '警告'
      detailedMessage: '是否确定要删除该模板集?'
      buttons:
        '是': -> return 1
        '否': -> return 0


  show_detail:->
    @parents('.emp-ui-snippets-management').view()?.showPanel(emp.EMP_SNIPPET_DETAIL, {back: emp.EMP_SHOW_UI_LIB}, [@snippet_path, @snippet_file, @snippet_pack])
