package com.NsFile;

public interface NsFileFilter {
    boolean accept(NsFile file) throws NsException;
}
