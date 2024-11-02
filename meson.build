project('valabar', 'vala', 'c')

add_project_arguments('-Wl,--export-dynamic', language: 'c')
add_project_arguments('-DWNCK_I_KNOW_THIS_IS_UNSTABLE', language: 'c')
dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('gmodule-2.0'),
    dependency('libwnck-3.0'),
    dependency('gdk-x11-3.0'),
]

sources = files(
    'valabar.vala',
    'taskbar.vala',
    'windowbutton.vala',
)

executable('valabar', sources, dependencies: dependencies)
