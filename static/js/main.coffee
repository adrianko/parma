(($) ->
    component_stash = {}
    modal = ""

    $.ajaxSetup
        beforeSend: (xhr, settings) ->
            unless (/^https?:.*/.test settings.url)
                xhr.setRequestHeader "X-CSRFToken", getCookie "csrftoken"

    $("a.new-task").on "click", ->
        $('#new-task-modal-title').val("")
        $('#new-task-modal-desc').val("")
        $('#new-task-modal-duration').val("0")
        $('#new-task-modal-duration-unit').val("0")
        $('#new-task-modal-users').val("0")
        modal = $(this).attr('data-category')
        undefined

    $("#new-task-modal-submit").on "click", ->
        component = 0
        if "task" not of component_stash
            component = 1
        $.ajax
            type: "POST"
            url: "/api/set/task/new"
            data:
                component: component
                data:
                    title: $('#new-task-modal-title').val()
                    category: modal
                    order: ($(".panel[data-category='"+modal+"'] .panel-body .well").length + 1)
                    desc: $('#new-task-modal-desc').val()
                    duration: $('#new-task-modal-duration').val()
                    duration_unit: $('#new-task-modal-duration-unit').val()
                    users: JSON.stringify ($(s).val() for s in $('#new-task-modal-users :selected'))
            success: (data) ->
                console.log data
                if component is 1
                    component_stash.task = data.data.components
                createTask()
        undefined

    createTask = () ->
        $("div.panel[data-category='"+modal+"'] .panel-body")
            .append(component_stash.task.replace '{{ title }}', $('#new-task-modal-title').val())
        $("#new-task-modal").modal("hide")
        undefined

    getCookie = (name) ->
        for cookie in document.cookie.split ";" when cookie and name is (cookie.split "=")[0]
            return decodeURIComponent cookie[(1 + name.length)...]
        null

    undefined
) jQuery
