#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Localize.py - Incremental localization on XCode projects
# João Moreno 2009
# http://joaomoreno.com/

from sys import argv
from codecs import open
from re import compile
from copy import copy
import os
import shutil

re_translation = compile(r'^"(.+)" = "(.+)";$')
re_comment_single = compile(r'^/\*.*\*/$')
re_comment_start = compile(r'^/\*.*$')
re_comment_end = compile(r'^.*\*/$')

def print_help():
	print u"""Usage: merge.py merged_file old_file new_file
Xcode localizable strings merger script. João Moreno 2009."""

class LocalizedString():
	def __init__(self, comments, translation):
		self.comments, self.translation = comments, translation
		self.key, self.value = re_translation.match(self.translation).groups()

	def __unicode__(self):
		return u'%s%s\n' % (u''.join(self.comments), self.translation)

class LocalizedFile():
	def __init__(self, fname=None, auto_read=False):
		self.fname = fname
		self.strings = []
		self.strings_d = {}

		if auto_read:
			self.read_from_file(fname)

	def read_from_file(self, fname=None):
		fname = self.fname if fname == None else fname
		try:
			f = open(fname, encoding='utf_16', mode='r')
		except:
			print 'File %s does not exist.' % fname
			exit(-1)
		
		line = f.readline()
		while line:
			comments = [line]

			if not re_comment_single.match(line):
				while line and not re_comment_end.match(line):
					line = f.readline()
					comments.append(line)
			
			line = f.readline()
			# debug log
			# print "processing line: " + line
			if line and re_translation.match(line):
				translation = line
			else:
				raise Exception('invalid file at line:\n' + line)
			
			line = f.readline()
			while line and line == u'\n':
				line = f.readline()

			string = LocalizedString(comments, translation)
			self.strings.append(string)
			self.strings_d[string.key] = string

		f.close()

	def save_to_file(self, fname=None):
		fname = self.fname if fname == None else fname
		try:
			f = open(fname, encoding='utf_16', mode='w')
		except:
			print 'Couldn\'t open file %s.' % fname
			exit(-1)

		for string in self.strings:
			f.write(string.__unicode__())

		f.close()

	def update_with(self, new):
		updated = LocalizedFile()
		for string in new.strings:
			if self.strings_d.has_key(string.key) and self.strings_d[string.key].value != string.value:
				new_string = copy(self.strings_d[string.key])
				new_string.comments = string.comments
				updated.strings.append(new_string)
				updated.strings_d[string.key] = new_string
			else:
				updated.strings.append(string)
				updated.strings_d[string.key] = string
		return updated


	def merge_with(self, new):
		merged = LocalizedFile()

#		for string in new.strings:
#			if self.strings_d.has_key(string.key):
#				new_string = copy(self.strings_d[string.key])
#				new_string.comments = string.comments
#				string = new_string
#
#			merged.strings.append(string)
#			merged.strings_d[string.key] = string

		# for string in new.strings:
		# 	if self.strings_d.has_key(string.key) and self.strings_d[string.key].value != string.value:
		# 		new_string = copy(self.strings_d[string.key])
		# 		new_string.comments = string.comments
		# 		string = new_string
		# 		merged.strings.append(string)
		# 		merged.strings_d[string.key] = string

		# BY-LYX: append the yet-to-translate lines at the end
		for string in new.strings:
			if not self.strings_d.has_key(string.key): 
				#or self.strings_d[string.key].value == string.value:
				self.strings.append(string)
				self.strings_d[string.key] = string
				# self.strings.append(string)
				# self.strings_d[string.key] = string
				# print 'new added: %s' % string

		# for string in merged.strings:
		# 	self.strings.append(string)
		# 	self.strings_d[string.key] = string

		return self

def merge_and_update(updated_file_name, file_name_1, file_name_2):
	try:
#		print 'loading ' + old_fname
		f1 = LocalizedFile(file_name_1, auto_read=True)
#		print 'loading ' + new_fname
		f2 = LocalizedFile(file_name_2, auto_read=True)
		updated = LocalizedFile(updated_file_name, auto_read=True)
	except Exception as inst:
		print 'Error: input files have invalid format.'
		print inst

	merged = LocalizedFile()
	merged = f1.merge_with(f2)
	updated = updated.update_with(merged)
	updated.save_to_file(updated_file_name)

#STRINGS_FILE = 'Localizable.strings'

def localize(path):
#	languages = [name for name in os.listdir(path) if name.endswith('.lproj') and os.path.isdir(name)]
#	languages = ["ar.lproj", "en.lproj", "ja.lproj", "th.lproj","vi.lproj"];
	langfiles = [
                 #"src/ar.lproj/Localizable.strings",
                 "Src/en.lproj/Localizable.strings",
                 #"src/fr.lproj/Localizable.strings",
                 #"src/th.lproj/Localizable.strings",
                 #"src/id.lproj/Localizable.strings",
                 #"src/vi.lproj/Localizable.strings",
                 "Src/zh-Hans.lproj/Localizable.strings",
                 #"src/zh-Hant.lproj/Localizable.strings",
#                 "src/ja.lproj/Localizable.strings"
				 
			];
	
	for langfile in langfiles:
		print 'processing: ' + langfile

		#langfile = merged = language + os.path.sep + f
		new = "Src/temp.lproj/Localizable.strings"
		oc = langfile + '.oc'
		swift = langfile + '.sw'
		old = langfile + '.old'

		# if os.path.isfile(langfile):
		# shutil.copy(langfile, old)
			#os.system('genstrings -s MOLocalizedString -q -o temp.lproj Classes/* Three20Core/*')
			# os.system('find . -name "*.m" -print0 | xargs -0 genstrings -s MOLocalizedString -q -o Src/temp.lproj')
			# os.system('find . -name "*.swift" -print0 | xargs -0 genstrings -s DJStringUtil.localize -q -o Src/temp.lproj')
			#os.rename(original, new)
			# merge(langfile, old, new)

			# os.system('find . -name "AddFriendSendRequestNetTask.swift" -print0 | xargs -0 genstrings -s DJStringUtil.localize -q -o Src/temp.lproj')
			# merge(langfile, oc, new)
		# else:
			#os.system('genstrings -s MOLocalizedString -q -o temp.lproj Classes/* Three20Core/*')
			# os.system('find . -name "*.m" -print0 | xargs -0 genstrings -s MOLocalizedString -q -o new')
			# os.system('find . -name "*.swift" -print0 | xargs -0 genstrings -s DJStringUtil.localize -q -o Src/temp.lproj')
			# os.system('find . -name "*.swift" -print0 | xargs -0 genstrings -s DJStringUtil.localize -q -o Src/temp.lproj')
			# os.rename(new, langfile)

		os.system('find . -name "*.m" -print0 | xargs -0 genstrings -s MOLocalizedString -q -o Src/temp.lproj')
		os.rename(new, oc)
		os.system('find . -name "*.swift" -print0 | xargs -0 genstrings -s DJStringUtil.localize -q -o Src/temp.lproj')
        os.rename(new, swift)
        merge_and_update(langfile, oc, swift)
        print 'OK'

if __name__ == '__main__':
	localize(os.getcwd())

