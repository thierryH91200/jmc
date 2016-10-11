//
//  SharedLibraryRequestHandler.swift
//  minimalTunes
//
//  Created by John Moody on 9/5/16.
//  Copyright © 2016 John Moody. All rights reserved.
//

import Cocoa
import CoreData

class SharedLibraryRequestHandler {
    
    func getSourceList() -> [NSMutableDictionary]? {
        let fetchRequest = NSFetchRequest(entityName: "SourceListItem")
        let predicate = NSPredicate(format: "(playlist != nil)")
        fetchRequest.predicate = predicate
        var results: [SourceListItem]?
        do {
            results = try managedContext.executeFetchRequest(fetchRequest) as? [SourceListItem]
        }catch {
            print("error: \(error)")
        }
        guard results != nil else {return nil}
        var serializedResults = [NSMutableDictionary]()
        for item in results! {
            serializedResults.append(item.dictRepresentation())
        }
        return serializedResults
        var finalObject: NSData?
        do {
            finalObject = try NSJSONSerialization.dataWithJSONObject(serializedResults, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print("error: \(error)")
        }
        //return finalObject
    }
    
    func getPlaylist(id: Int) -> [NSMutableDictionary]? {
        let playlistRequest = NSFetchRequest(entityName: "SongCollection")
        let playlistPredicate = NSPredicate(format: "id = '\(id)'")
        playlistRequest.predicate = playlistPredicate
        let result: SongCollection? = {
            do {
                let thing = try managedContext.executeFetchRequest(playlistRequest) as! [SongCollection]
                if thing.count > 0 {
                    return thing[0]
                } else {
                    return nil
                }
            } catch {
                print("error: \(error)")
            }
            return nil
        }()
        print(result)
        guard result != nil else {return nil}
        let playlistSongsRequest = NSFetchRequest(entityName: "Track")
        let id_array = result?.track_id_list
        let playlistSongsPredicate = NSPredicate(format: "id in %@", id_array!)
        playlistSongsRequest.predicate = playlistSongsPredicate
        let results: [Track]? = {
            do {
                let thing = try managedContext.executeFetchRequest(playlistSongsRequest) as! [Track]
                if thing.count > 0 {
                    return thing
                } else {
                    return nil
                }
            } catch {
                print("error: \(error)")
            }
            return nil
        }()
        print(results)
        guard results != nil else {return nil}
        var serializedTracks = [NSMutableDictionary]()
        for track in results! {
            serializedTracks.append(track.dictRepresentation())
        }
        return serializedTracks
        var finalObject: NSData?
        do {
            finalObject = try NSJSONSerialization.dataWithJSONObject(serializedTracks, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print("error: \(error)")
        }
        //return finalObject
    }
    
    func getSong(id: Int) -> NSData? {
        let songRequest = NSFetchRequest(entityName: "Track")
        let songPredicate = NSPredicate(format: "id = %i", id)
        songRequest.predicate = songPredicate
        let result: Track? = {
            do {
                let thing = try managedContext.executeFetchRequest(songRequest) as! [Track]
                if thing.count > 0 {
                    return thing[0]
                } else {
                    return nil
                }
            } catch {
                print(error)
            }
            return nil
        }()
        guard result != nil else {return nil}
        let trackURL = NSURL(string: result!.location!)
        let trackData = NSData(contentsOfURL: trackURL!)
        return trackData
    }
}