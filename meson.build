project('valabar', 'vala', 'c')

vapi_dir = meson.current_source_dir()
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

add_project_arguments('-Wl,--export-dynamic', language: 'c')
add_project_arguments('-DWNCK_I_KNOW_THIS_IS_UNSTABLE', language: 'c')
dependencies = [
    dependency('gio-unix-2.0'),
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('gmodule-2.0'),
    dependency('libwnck-3.0'),
    dependency('libbamf3'),
]

sources = files(
    'valabar.vala',
    'appchooser.vala',
    'taskbar.vala',
    'appbutton.vala',
    'appbox.vala',
    'cpuusagemeter.vala',
)

configure_file(input : 'style.css', output : 'style.css', copy: true)
configure_file(input : 'valabar.ui', output : 'valabar.ui', copy: true)
configure_file(input : 'border.svg', output : 'border.svg', copy: true)

executable('valabar', sources, dependencies: dependencies, install : true, install_dir : join_paths(get_option('prefix'), 'github/mybar'))
install_data('style.css', install_dir : join_paths(get_option('prefix'), 'github/mybar'))
install_data('valabar.ui', install_dir : join_paths(get_option('prefix'), 'github/mybar'))
install_data('border.svg', install_dir : join_paths(get_option('prefix'), 'github/mybar'))
