#!/usr/bin/env python

# for non-list/dict, CHANGE_TO -> variables replace previous values
# for 'list' ,       ADD_TO     -> append to list
#                    EXCLUDE_FROM -> remove element from list
# for 'dict' ,       REPLACE_WITH  -> replace matching keys 
#                                    as CHANGE_TO, ADD_TO or EXCLUDE_FROM

import pprint
import argparse
import sys
import os
import errno
import re

class dryRun(Exception): pass

class ConfigParseError(dryRun):
      def __init__(self, msg, config_filename, orig_exc):
         self.config_filename = config_filename
         self.orig_exc = orig_exc
         Exception.__init__(self, msg)

class CmdLine():
   def __init__(self, argvList):
      self.json_dir = '../json'

      # env_name: '-e' [dev, qa, uat, prod, ...] 
      # app_name:'-a'  [ 'eq', ... ]
      # app_use: '-u' [ centos_6u6, rh_7.2, ...]
      # hw_name: '-m' [ hp_dl_360_gen9, hp_dl_360_gen10, ...]
      # dc_name: '-l' [ rfp, sec, lnd, ....]
      # host_name: '-n' 

      self.env_name = ''
      self.app_name = ''
      self.app_use  = 'all'
      self.hw_name  = ''
      self.dc_name = ''
      self.host_name = ''

      # This is JSON configuration file name and key value to look in to
      self.configFile  = ''
      self.configKey  = ''
      self.c = {}

      self.parseCmdLine(argvList)

      print(self.hw_name)

      # Read YAML in to main_config
      self.main_config = self.read_config(self.configFile)
     
      #print(self.main_config)

      # parse JSON
      self.xyz(self.configKey, self.main_config)
      #self.parseJSON(self.main_config[self.configKey])
      #print('%s %s' % ('Applying', self.configFile))


   def parseCmdLine(self, cmdLine):
       parser = argparse.ArgumentParser(description="parse josn files")
       parser.add_argument('-m', action="store", dest="model")
       parser.add_argument('-n', action="store", dest="host_name")
       parser.add_argument('-u', action="store", dest="unix_os")
       parser.add_argument('-l', action="store", dest="location")
       parser.add_argument('-a', action="store", dest="app_name")
       parser.add_argument('-e', action="store", dest="env_name")
       parser.add_argument('-r', action='store_true', dest="run" )
       parser.add_argument('command', nargs='*', action="store")

       args = parser.parse_args(cmdLine)
       
       if (not args.run):
          print(args.model)
          raise dryRun

       # command validation
       
       self.hw_name = args.model

       self.configFile = os.path.join(self.json_dir, self.hw_name)
       self.configKey  = '%s' % (self.hw_name)
          
   def read_config(self, config_filename):
        from yaml import load
        from os.path import exists

        if not exists(config_filename): return

        with open(config_filename) as f:
             try:
                  return load(f)
             except ValueError as exc:
                  msg = 'Error parsing %s:\n %s' % (config_filename, exc)
                  raise ConfigParseError(msg, config_filename, exc)

   def xyz(self, k, d):
       tmp={}
       hc_tmp={}
       hc_tmp1={}
       tmp[k]=d[k]
       if d[k].has_key('extends'):
          extend_keys=d[k].pop('extends')
          print(extend_keys)
          for ek in extend_keys:
             print('Before')
             pprint.pprint(hc_tmp)
             print('Before-End')
             tmp[ek]=self.parseJSON(ek, m=hc_tmp)
             hc_tmp.update(tmp[ek])
             print(ek)
             hc_tmp1=my_func(hc_tmp)
             print('uuuu')
             pprint.pprint(hc_tmp)
             print('uuuu-End')
             pprint.pprint(hc_tmp1)
             print('ffff')
             hc_tmp=hc_tmp1
             print(hc_tmp['pkg_list'])
             #d.update( my_func(self.parseJSON(ek, m={})))
             
       #pprint.pprint(tmp)
       print('gggg')
       hc_tmp.update(d[k])
       pprint.pprint(my_func(hc_tmp))
       #pprint.pprint(my_func(d))
       return(d)
       
   def parseJSON(self, k, m):
       d = self.read_config(self.json_dir +'/'+ k )[k]
       #print('sss')
       #pprint.pprint(d)
       #print('sss-End')

       if not d.has_key('extends'):
           m.update( my_func(d))
           return(m)

       for j in d.pop('extends'):
           m.update( my_func( self.parseJSON(j,d) ) )
           print( 'Applying ' + self.json_dir +'/'+ j )

           #tmp_dict=my_func(self.c)
           #self.c.update(tmp_dict)

       return(m)

#
def manage_list(v, nv, r):
  #print('called from manage_list: %s' % r)
  #print(v)
  #print(nv)
  #print('called from manage_list - End')
  if (r in ['ADD_TO']):
     try:
        #v.extend([x for x in nv if not any(re.search(y, x) for y in v)])
        v.extend(nv)
     except TypeError as exc:
        v.extend(nv)
  
  if (r in ['EXCLUDE_FROM']):
     v=reduce(lambda x,y : filter(lambda z: z!=y,x),nv,v)
  return(v)

def my_func(a):
  ret_dict={}
  done_key_list=[]

  for k,v in a.iteritems():
     reserved_word=''
     if (len(k.split('_')) > 2):
        reserved_word='_'.join(k.split('_')[:2])
        if (reserved_word in [
                'ADD_TO', 
                'EXCLUDE_FROM', 
                'REPLACE_WITH', 
                'CHANGE_TO'
                ]):
           var='_'.join(k.split('_')[2:])
        else:
           var=k
     else:
        var=k
 
     if (isinstance(v, list)):
        if (reserved_word in ['ADD_TO', 'EXCLUDE_FROM']):
           done_key_list.append('%s' % (var))
 
           # check ret_dict if var exists or use from previous dict 

           # empty list
           pv=[]

           if (a.has_key(var)):
              pv=ret_dict[var] if (ret_dict.has_key(var)) else a[var]

           ret_dict[var]=manage_list(pv, v, reserved_word)
  
        else:
           print('PPPP')
           pprint.pprint(a[var])
           print(done_key_list)
           pprint.pprint(v)
           print('PPPP-End')
           if (var not in done_key_list):
              ret_dict[var]=v
 
     if (not isinstance(v, list) and not isinstance(v, dict)):
        if (reserved_word in ['REPLACE_WITH']):
           done_key_list.append(var)
           ret_dict[var]=a['%s_%s' % (reserved_word, var)]
        else:
           if (var not in done_key_list):
              ret_dict[var]=v
 
     if (isinstance(v, dict)):
        if (reserved_word in ['CHANGE_TO']):
           done_key_list.append(var)
           tmp_dict={}

           for k1,v1 in v.iteritems():
               tmp_dict[k1]=v1

           if (a.has_key(var)):
              for k1,v1 in a[var].iteritems():
                  tmp_dict[k1]=v1
 
           ret_dict[var]=my_func(tmp_dict)
        else:                               
           if (var not in done_key_list):
              ret_dict[var]=v
 
  return(ret_dict)

u=CmdLine(sys.argv[1:])

print('End')
pprint.pprint(u.c)
