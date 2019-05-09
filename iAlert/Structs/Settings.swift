//
//  Settings.swift
//  iAlert
//
//  Created by Assaf Tayouri on 03/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation

struct Settings {
    public static var shared:Settings = Settings()
    
    var languageId:String!{
        didSet{
            language = getLanguageEnum(with: languageId)
        }
    }
    private(set) var language:Language!
    {
        didSet
        {
         let associatedValues = language.associatedValues
            GMSLanguageId = associatedValues.GMSLanguageId
            direction = associatedValues.direction
            saveCurrentLanguageId(for: languageId)
        }
    }
    
    var sound:Bool!{
        didSet{
            saveSoundConfiguration(for: sound)
        }
    }
    
    private(set) var GMSLanguageId:String!
    
    private(set) var direction:Direction!
    
    fileprivate init()
    {
        var language:Language!
        if let languageId = self.loadCurrentLanguageId(),let validateLanguage = Language.getLanguage(of: languageId){
                language = validateLanguage
        }
        else
        {
            language = Language.DEFAULT_LANGUAGE
            self.saveCurrentLanguageId(for: language.associatedValues.languageId)
        }
        
        let languageAssociatedValues = language.associatedValues
       
        self.language = language
        self.direction = languageAssociatedValues.direction
        self.GMSLanguageId = languageAssociatedValues.GMSLanguageId
        self.languageId = languageAssociatedValues.languageId
        
        if let sound = loadSoundConfiguration()
        {
            self.sound = sound
        }
        else
        {
            self.sound = true
            saveSoundConfiguration(for: self.sound)
        }
    }
    
    
    private func getLanguageEnum(with languageId:String)->Language
    {
        guard let language = Language.getLanguage(of: languageId)
            else{return Language.DEFAULT_LANGUAGE}
        return language
        
    }
    
    private func loadCurrentLanguageId()->String?
    {
        return UserDefaults.standard.string(forKey: Language.PREFFERED_LANGUAGE)
    }
    
    private func saveCurrentLanguageId(for languageId:String)
    {
        UserDefaults.standard.set(languageId, forKey: Language.PREFFERED_LANGUAGE)
        UserDefaults.standard.synchronize()
    }
    
    private func loadSoundConfiguration()->Bool?
    {
        return UserDefaults.standard.bool(forKey: ConstsKey.SOUND)
    }
    
    private func saveSoundConfiguration(for soundConf:Bool)
    {
        UserDefaults.standard.set(soundConf, forKey: ConstsKey.SOUND)
        UserDefaults.standard.synchronize()
    }
    
    
}
