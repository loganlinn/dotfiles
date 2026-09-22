import json
from kittens.tui.handler import result_handler

def main(args):
    pass

@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    rows = []
    for tm in boss.all_tab_managers:
        screen = tm.tab_bar.screen
        rows.append({'os_window_id': tm.os_window_id, 'tab_bar': str(screen.line(0)),
                     'tabs': [{'id':t.id,'window_ids':[w.id for w in t]} for t in tm]})
    callbacks = {str(w.id): {name:[f.__code__.co_filename for f in getattr(w.watchers,name)]
                  for name in ('on_resize','on_close','on_title_change','on_cmd_startstop','on_set_user_var')}
                 for w in boss.window_id_map.values()}
    return json.dumps({'display':rows, 'callbacks':callbacks,
                      'timer':getattr(boss,'_logan_activity_timer',None)})
