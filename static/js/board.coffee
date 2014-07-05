(($) ->
    component_stash = {}
    home_board = ""
    board_id = ""

    $(document.body).on "click", "a.new-board", ->
        $("#new-board-modal-title").val("")
        undefined

    $(document.body).on "click", "#new-task-modal-submit", ->
        component = 0
        if "task" not of component_stash
            component = 1
        $.ajax
            type: "POST"
            url: "/api/set/task/new"
            data:
                component: component
                data:
                    title: $("#new-task-modal-title").val()
                    category: new_task_category
                    order: ($(".panel[data-category='"+new_task_category+"'] .panel-body .well").length + 1)
                    desc: $("#new-task-modal-desc").val()
                    duration: $("#new-task-modal-duration").val()
                    duration_unit: $("#new-task-modal-duration-unit").val()
                    users: JSON.stringify ($(s).val() for s in $("#new-task-modal-users :selected"))
            success: (data) ->
                if component is 1
                    component_stash.task = data.data.components
                task = component_stash.task
                task = task.replace "{{ title }}", $("#new-task-modal-title").val()
                task = task.replace "{{ id }}", data.data.id
                $("div.panel[data-category='"+new_task_category+"'] .panel-body .task-list")
                    .append(task)
                $("#new-task-modal").modal("hide")
            error: (jqXHR, textStatus, err) ->
                console.log err
        undefined

    $(document.body).on "click", "#new-board-modal-submit", ->
        component = 0
        if "boarditem" not of component_stash
            component = 1
        title = $("#new-board-modal-title").val()
        $("#new-board-modal").modal "hide"
        $.ajax
            type: "POST"
            url: "/api/set/board/new"
            data:
                component: component
                title: title
            success: (data) ->
                console.log data
                if data.code != 200
                    console.log "ERROR: "+data.code
                if component is 1
                    component_stash.boarditem = data.data.components
                board = component_stash.boarditem
                board = board.split "{{ id }}"
                board = board.join data.data.id
                board = board.replace "{{ title }}", title
                $(".boards").eq(0).append board
                $("#new-board-modal").modal "hide"
            error: (jqXHR, textStatus, err) ->
                console.log err
        undefined

    $(document.body).on "click", ".board-link", ->
        window.location.href = $(@).attr("data-href")
        undefined

    $(document.body).on "click", ".board-edit", ->
        board_id = $(@).parent().parent().closest("li").attr "data-board"
        $("#edit-board-modal-title").val($(@).closest(".btn-group").find(".board-link").eq(0).text())
        $("#edit-board-modal").modal "show"
        undefined

    $(document.body).on "click", "#edit-board-modal-submit", ->
        title = $("#edit-board-modal-title").val()
        $.ajax
            type: "POST"
            url: "/api/set/board/update"
            data:
                id: board_id
                title: title
            success: (data) ->
                console.log data
                if data.code != 200
                    console.log "ERROR: "+data.code
                $("ul.boards li[data-board='"+board_id+"'] .btn-group .board-link").text title
                $("#edit-board-modal").modal "hide"
                board_id = ""
            error: (jqXHR, textStatus, err) ->
                console.log err
        undefined

    $(document.body).on "click", ".board-delete", ->
        home_board = $(@).attr "data-task"
        $("#delete-board-modal").modal "show"
        undefined

    $(document.body).on "click", "#delete-board-no", ->
        $("#delete-board-modal").modal "hide"
        undefined

    $(document.body).on "click", "#delete-board-yes", ->
        $.ajax
            type: "POST"
            url: "/api/set/board/delete"
            data:
                id: home_board
            success: (data) ->
                if data.code != 200
                    console.log "ERROR: "+data.code
                $("ul.boards li[data-board='"+home_board+"']").remove()
                $("#delete-board-modal").modal "hide"
                home_board = ""
            error: (jqXHR, textStatus, err) ->
                console.log err
        undefined
) jQuery
