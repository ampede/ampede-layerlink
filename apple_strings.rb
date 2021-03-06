def apple_strings( entries )
  buffer = ''
  write_apple_strings( entries, buffer )
  buffer
end

def write_apple_strings( entries, out = $stdout )
  out << %q(/* AUTOGENERATED -- DO NOT MODIFY! */)
  out << "\n\n"
  out << %q(/* Localized versions of Info.plist keys */)
  out << "\n\n"
  entries.each do |entry|
    out << "#{entry} = \"#{ eval( entry ) }\";\n"
  end
end
