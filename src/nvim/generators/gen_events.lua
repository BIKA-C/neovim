local fileio_enum_file = arg[1]
local names_file = arg[2]

local auevents = require('auevents')
local events = auevents.events
local aliases = auevents.aliases

local enum_tgt = io.open(fileio_enum_file, 'w')
local names_tgt = io.open(names_file, 'w')

enum_tgt:write('typedef enum auto_event {')
names_tgt:write([[
static const struct event_name {
  size_t len;
  char *name;
  event_T event;
} event_names[] = {]])

for i, event in ipairs(events) do
  enum_tgt:write(('\n  EVENT_%s = %u,'):format(event:upper(), i - 1))
  names_tgt:write(('\n  {%u, "%s", EVENT_%s},'):format(#event, event, event:upper()))
  if i == #events then  -- Last item.
    enum_tgt:write(('\n  NUM_EVENTS = %u,'):format(i))
  end
end

for _, v in ipairs(aliases) do
  local alias = v[1]
  local event = v[2]
  names_tgt:write(('\n  {%u, "%s", EVENT_%s},'):format(#alias, alias, event:upper()))
end

names_tgt:write('\n  {0, NULL, (event_T)0},')

enum_tgt:write('\n} event_T;\n')
names_tgt:write('\n};\n')

local gen_autopat_events = function(name)
  names_tgt:write(string.format('\nstatic AutoPat *%s[NUM_EVENTS] = {\n ', name))
  local line_len = 1
  for _ = 1,((#events) - 1) do
    line_len = line_len + #(' NULL,')
    if line_len > 80 then
      names_tgt:write('\n ')
      line_len = 1 + #(' NULL,')
    end
    names_tgt:write(' NULL,')
  end
  if line_len + #(' NULL') > 80 then
    names_tgt:write('\n  NULL')
  else
    names_tgt:write(' NULL')
  end
  names_tgt:write('\n};\n')
end

gen_autopat_events("first_autopat")
gen_autopat_events("last_autopat")

enum_tgt:close()
names_tgt:close()
