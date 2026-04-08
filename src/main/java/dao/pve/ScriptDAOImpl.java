package dao.pve;

import dto.pve.BuildMatchupDTO;
import dto.pve.BuildStatBonusDTO;
import dto.pve.ScriptDTO;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class ScriptDAOImpl implements ScriptDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NS = "script.";

    // ── 대본 CRUD ─────────────────────────────────────────
    @Override 
    public int insertScript(ScriptDTO s) { 
        return sqlSession.insert(NS+"insertScript", s); 
    }

    @Override 
    public int updateScript(ScriptDTO s) { 
        return sqlSession.update(NS+"updateScript", s); 
    }

    @Override 
    public int deleteScript(int id) { 
        return sqlSession.delete(NS+"deleteScript", id); 
    }

    @Override 
    public int deleteScriptsByMyBuildId(int myBuildId) { 
        return sqlSession.delete(NS+"deleteScriptsByMyBuildId", myBuildId); 
    }
    
    @Override 
    public int deleteScriptsByBuildIds(Map<String, Object> params) { 
        return sqlSession.delete(NS+"deleteScriptsByBuildIds", params); 
    }

    @Override 
    public List<ScriptDTO> selectScriptsByMatchup(Map<String, Object> params) { 
        return sqlSession.selectList(NS+"selectScriptsByMatchup", params); 
    }

    @Override 
    public List<ScriptDTO> selectScriptForPlay(Map<String, Object> params) { 
        return sqlSession.selectList(NS+"selectScriptForPlay", params); 
    }

    @Override 
    public List<ScriptDTO> selectScriptSummaryByMyBuild(int myBuildId) { 
        return sqlSession.selectList(NS+"selectScriptSummaryByMyBuild", myBuildId); 
    }

    // ── 빌드 종족 상성 ────────────────────────────────────
    @Override 
    public int insertOrUpdateMatchup(BuildMatchupDTO m) { 
        return sqlSession.insert(NS+"insertOrUpdateMatchup", m); 
    }

    @Override 
    public int deleteMatchupsByBuildId(int bid) { 
        return sqlSession.delete(NS+"deleteMatchupsByBuildId", bid); 
    }

    @Override 
    public List<BuildMatchupDTO> selectMatchupsByBuildId(int bid) { 
        return sqlSession.selectList(NS+"selectMatchupsByBuildId", bid); 
    }

    // ── 빌드 능력치 가산점 ────────────────────────────────
    @Override 
    public int insertOrUpdateStatBonus(BuildStatBonusDTO b) { 
        return sqlSession.insert(NS+"insertOrUpdateStatBonus", b); 
    }

    @Override 
    public int deleteStatBonusesByBuildId(int bid) { 
        return sqlSession.delete(NS+"deleteStatBonusesByBuildId", bid); 
    }

    @Override 
    public List<BuildStatBonusDTO> selectStatBonusesByBuildId(int bid) { 
        return sqlSession.selectList(NS+"selectStatBonusesByBuildId", bid); 
    }
}