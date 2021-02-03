---
title: Todotxt, a neuron to manage todolist compatible with todotxt format!
date: 2017-02-28
tags:
- kalliope
- home_automation
- tototxt
---


## Introduction

This neuron allow [Kalliope](http://github.com/kalliope-project/kalliope) to manage todolists. It leverages the [todotxt](http://todotxt.com) methodology and rules.

With the current state of the neuron, you'll be able to list (and filter), add and delete tasks in your todolists.


## Why todotxt ?

### Ways of managing a todolist with Kalliope:

As of no todolist neuron exists so far, I needed to created this feature from scratch. I had the following possibilities:

* Saas "fashion" offering like [remember the milk](), [Google keep](https://keep.google.com), [Google calendar tasks](https://calendar.google.com) or even [evernote](https://evernote.com)
* Local todolist application like [Todolist](http://todolist.site/) or [Taskwarrior](https://taskwarrior.org/)
* Self hosted todolist server app like taskwarrior [taskwarrior server](https://taskwarrior.org/docs/taskserver/setup.html)
* Simple text file
* I'm sure a lot of other way

All of them have advantages and drawbacks, but I had personal requirements:

* Open Source software (what else…)
* Data privacy (keeping my todolist mine)
* Simplicity (I won't manage reporting, diagram and very complex tasks via Kalliope)

### The choice

Looking at the lists of options and requirements above, only 2 options were attractive to me:

* Taskwarrior + taskwarrior server: this was my main idea for a long time, as a previous long time user of Taskwarrior. This todolist tool is extremely powerful and can manage all aspects of a todolist as well as creating reports etc. Cli is very complete (and can be complex if you have a lot of arguments / commands) but it for me the "Rolls-Royce" of cli todolist tools. The server setup and a full configuration can takes a bit of time though.
* Simple text file: I like the idea but lacked flexibility. It would have meant simple file per todo list (one for groceries, one for reminders, …), but the integration with Kalliope would be simple ass reading/writing a text file. As well, a text file can be read on any devices without a required application being installed. Sharing text file todolists is simple (eg: mail, scp, rsync, … ) But that will be part of another blog post about how I manage my grocery lists via Kalliope.


### The solution: todotxt !

If I had 2 words to describe todotxt, it would be : **simply powerful**

Todotxt is simple concept (not even an software per say) to manage todolists via a single text files, with only a very small set of rules for writing tasks in it. I encourage you to go to [their website](https://todotxt.com) and learn about it, it will take you 5 minutes to understand the full concept. You can find the rules set [here](https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format) and an example of a [todotxt file here](http://todotxt.com/todo.txt)

If you already use todotxt or like its simplicity, this neuron is for you.

As well, if you don't really care about sharing Kalliope's todolist on the cloud or with your other devices and use other todolist app for your own work/personal todolist, you can of course leverage this neuron as well :)


## The neuron

### What it does

* Manage tasks based on todotxt model: priority, project, context, completeness
* List / filter items from todotxt files
* Add elements to list (with arguments like priority and projects)


### What it could do in future release

* Get / Delete searched entry
* Mark as complete / Update tasks (instead of delete)
* Manage multi projects and contexts in order.

### Installation

Usual Kallipoe way:

```bash
  kalliope start install --git-url https://github.com/bacardi55/kalliope-todotxt.git
```

### Configuration

As usual, the [README](https://github.com/bacardi55/kalliope-todotxt/blob/master/README.md) is the most up to date documentation about arguments / return values.

#### arguments:

| parameter    | required | default | choices                   | comments                       |
|--------------|----------|---------|---------------------------|--------------------------------|
| action       | yes      |         | 'get', 'add' or 'del'     | The action to launch           |
| todotxt_file | yes      |         | String                    | The path to the todotxt file   |
| priority     | No       |         | 'A', 'B' or 'C'           | The priority of the task       |
| project      | No       |         | String                    | The project of the task        |
| context      | No       |         | String                    | The context of the task        |
| complete     | No       | False   | Boolean: False or True    | If the task is complete or not |
| content      | No       |         | String                    | The content of the task        |

**Additional notes:**

* If action is 'add':
  * Content argument is mandatory
  * Priority/context/complete/projects will be added in the raw line in text file
* If action is 'get', adding priority / project / context will filter the results (see brain example below)
* If action is 'del', every tasks that match the given priority/project/context will be deleted.


#### Return values:

Only necessary when the neuron use a template to say something

| name       | description                         | type          | sample                  |
|------------|-------------------------------------|---------------|-------------------------|
| action     | The action launched                 | string        | 'get', 'del' or 'add'   |
| task_list  | list of tasks (for get action only) | list of tasks | [task1, taks2, task3].  |
| count      | The number of returned element      | Integer       | 2                       |
| added_task | string value                        | Task object¹  | Task object¹            |

**Additional notes:**

* If action is 'get':
  * Count contains the number of return tasks in tasks_lists
  * Task_lists contains the list of task object¹
  * add_task is unset
* If action is 'del':
  * Count contains the number of deleted tasks
  * added_task is unset
  * task_list is unset
* If action is 'add':
  * Count is unset
  * added_task contain a Task object¹
  * task_list is empty


**Task Object:** The task object contains the following properties:

* Task.raw: the raw line representing the task in the todotxt file.
* Task.task_id: The task id (number of line)
* Task.task: The cleaned text of a text
* Task.priority: The priority
* Task.project: A list of project name
* Task.context = A list of context name
* Task.creation_date: Creation date if precised
* Task.complete: Is the task complete?
* Task.completion_date: Completion date if completed task
* Task.due_date: Due date if precised.

You can reuse all these properties in ```template_file``` or ```file_template``` for each task objects (added_task or each element of task_list).



#### Brain examples

Get tasks, no filter.

```bash
  - name: "Get-all-tasks"
    signals:
      - order: "Get all my tasks"
    neurons:
      - todotxt:
          action: "get"
          todotxt_file: "resources/neurons/todotxt/samples/todo.txt"
          file_template: "templates/en_todotxt.j2"
```

Get tasks with specific filters

```yaml
  - name: "Get-specific-items"
    signals:
      - order: "Get my super list"
    neurons:
      - todotxt:
          action: "get"
          todotxt_file: "resources/neurons/todotxt/samples/todo.txt"
          project: "project"
          priority: "A"
          context: "context"
          complete: False
          file_template: "templates/en_todotxt.j2"
```

Add item to list

```yaml
  {% raw %}
    - name: "add-item-to-super-list"
      signals:
        - order: "add {{content}} to the super list"
      neurons:
        - todotxt:
            action: "add"
            todotxt_file: "resources/neurons/todotxt/samples/todo.txt"
            project: "project"
            priority: "A"
            context: "context"
            complete: False
            args:
                - content
            say_template: "Task {{added_task.task}} has been added to the super project with priority {{added_task.priority}}"
  {% endraw %}
```

You could also add arguments with value coming from voice order directly:

```yaml
  {% raw %}
    - name: "add-item-to-super-list"
      signals:
        - order: "add {{content}} to the {{project}} list with priority {{priority}} and context {{context}}"
      neurons:
        - todotxt:
            action: "add"
            todotxt_file: "resources/neurons/todotxt/samples/todo.txt"
            complete: False
            args:
                - content
                - project: "project"
                - priority: "A"
                - context: "context"
            say_template: "Task {{added_task.task}} has been added to the super project with priority {{added_task.priority}}"
  {% endraw %}
```

Remove items that match filters from global list.

```yaml
  {% raw %}
    - name: "clear-super-list"
      signals:
        - order: "clear super list"
      neurons:
        - todotxt:
            action: "del"
            todotxt_file: "resources/neurons/todotxt/samples/todo.txt"
            project: "project"
            priority: "A"
            context: "context"
            complete: False
            say_template: "{{count}} items have been deleted"
  {% endraw %}
```

#### Template examples

```jinja
  {% raw %}
  {% if count > 0 %}
      Your list contains:
      {% for task in task_list %}
          {{ task.text }}
      {% endfor %}
  {% else %}
      You don't have any item in your list
  {% endif %}

  {% endraw %}
```
Or you can simply use the ```say_template``` argument, eg for adding a task:

```yaml
  {% raw %}
  say_template: "Task {{added_task.task}} has been added to the grocery list"
  {% endraw %}
```

As usual, the [sample directory](https://github.com/bacardi55/kalliope-todotxt/tree/master/samples) contains more example of brains and templates.
