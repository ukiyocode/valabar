project('valabar', 'vala', 'c')

add_project_arguments('-D__USE_TIME_BITS32', language: 'c')
add_project_arguments('-O', language: 'c')
vapi_dir = meson.current_source_dir()
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
add_project_arguments('-Wl,--export-dynamic', language: 'c')
add_project_arguments('-DWNCK_I_KNOW_THIS_IS_UNSTABLE', language: 'c')
add_project_link_arguments('-lm', language: 'c')

dependencies = [
    dependency('gio-unix-2.0'),
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('gmodule-2.0'),
    dependency('libwnck-3.0'),
    dependency('libbamf3'),
    dependency('alsa'),
    meson.get_compiler('vala').find_library('posix'),
    #dependency('dbusmenu-glib-0.4'),
    #dependency('libpulse'),
]

sources = files(
    'valabar.vala',
    'appchooser.vala',
    'taskbar.vala',
    'appbutton.vala',
    'appbox.vala',
    'cpuusagemeter.vala',
    'graph.vala',
    'systemtray.vala',
    'notifierwatcher.vala',
    'notifierhost.vala',
    'traychild.vala',
    'clock.vala',
    'volume.vala',
    'logger.vala',
    'battery.vala',
    'popup.vala',
)


configure_file(input : 'style.css', output : 'style.css', copy: true)
configure_file(input : 'valabar.ui', output : 'valabar.ui', copy: true)

executable('valabar', sources, dependencies: dependencies, install : true,
    install_dir : join_paths(get_option('prefix'), 'github/mybar'))
install_data('style.css', install_dir : join_paths(get_option('prefix'), 'github/mybar'))
install_data('valabar.ui', install_dir : join_paths(get_option('prefix'), 'github/mybar'))
install_subdir('images', install_dir : join_paths(get_option('prefix'), 'github/mybar'))
